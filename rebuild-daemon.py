"""
Start this to automatically build the app using Brunch (not using Brunch's watching, but using own file change
recognition of any file in the "src" folder) and (optionally) to copy it to the Android project. This only triggers
for changed files (modification date), not for deletions.

Pass the "--target=android" parameter to copy the result to the Android project (to "assets/www" folder). Existing files
in that directory are deleted.

For iOS, the "--target=ios" parameter copies the result to the "www" folder in the iOS project.

@author:
    Andreas Sommer
@note:
    Requires the Python package watchdog (install with `pip install watchdog`, see also
    http://pypi.python.org/pypi/watchdog).
"""

from __future__ import print_function

from datetime import datetime
from distutils import dir_util
from itertools import chain
from optparse import OptionParser
import os
import re
import shutil
import sys
import threading
import time
import traceback
from subprocess import Popen
import watchdog.events
import watchdog.observers
try:
    import gntp.notifier
except ImportError:
    gntp = None

cwd = os.path.abspath(os.path.dirname(__file__))
assert(all(os.path.exists(os.path.join(cwd, dirName)) for dirName in ("src", "android", "ios", "extra_assets", "i18n")))

parser = OptionParser()
parser.add_option("--target", default=None, help="Target platform", metavar="android|ios|web")
parser.add_option("--debug", default=False, action="store_true", help="Debug mode (no minification)", metavar="true|false")
(options, args) = parser.parse_args()
assert(not args)

target = options.target
debug = options.debug

if target not in ("android", "ios", "web"):
    raise AssertionError("Invalid target specified")


def copy_build_output(friendly_platform_name, platform_name, output_path_list):
    if output_path_list is not None:
        # Assume that the parent directory of "www" exists
        os.path.join(cwd, *(output_path_list[:-1]))

        print("%s: Copying to %s project..." % (format_date(time.time()), friendly_platform_name))
        output_directory = os.path.join(cwd, *output_path_list)

        if os.path.exists(output_directory):
            shutil.rmtree(output_directory)

        shutil.copytree(os.path.join(cwd, "src", "public"), output_directory)
    else:
        output_directory = os.path.join(cwd, "src", "public")

    extra_assets_directory = os.path.join(cwd, "extra_assets", platform_name)

    if os.path.exists(extra_assets_directory):
        dir_util.copy_tree(extra_assets_directory,
                           output_directory,
                           update=False)

    # i18n directory copied as "i18n" folder to work with i18next directory structure defined in application.coffee
    # (see also http://jamuhl.github.com/i18next/)
    if not os.path.isdir(os.path.join(output_directory, "i18n")):
        os.mkdir(os.path.join(output_directory, "i18n"))
    dir_util.copy_tree(os.path.join(cwd, "i18n"),
                       os.path.join(output_directory, "i18n"),
                       update=True)


def copy_build_output_to_android_project():
    copy_build_output("Android", "android", ("android", "assets", "www"))


def copy_build_output_to_ios_project():
    copy_build_output("iOS", "ios", ("ios", "www"))


def copy_build_output_to_web_project():
    copy_build_output("Web (browser testing)", "web", None)


def create_target_specific_config_files():
    with open(os.path.join(cwd, "src", "config.coffee.template"), "rU") as f:
        template = f.read().decode("utf-8")

    for target in ("android", "ios", "web"):
        if "<MAGIC>\n" not in template:
            raise AssertionError

        target_variables = ("TARGET = '%s'\n"
                            "DEBUG = %s\n"
                            % (target, "true" if debug else "false"))

        content = ("# WARNING: AUTOGENERATED FILE. DO NOT CHANGE\n\n" +
                   target_variables +
                   template[template.index("<MAGIC>\n") + 8:])

        with open(get_target_specific_config_filename(target), "wb") as out_file:
            out_file.write(content.encode("utf-8"))


def format_date(timestamp):
    return datetime.fromtimestamp(timestamp).strftime("%d.%m.%Y %H:%M:%S")


def get_target_specific_config_filename(target):
    return os.path.join(cwd, "src", "config-%s.autogen.coffee" % target)


def notify_error():
    if gntp is None:
        return

    try:
        growl.notify(
            noteType='error',
            title='BUILD FAILED!',
            description='',
            icon='http://i.imgur.com/yYlIE.png',
            sticky=False,
            priority=1
        )
    except Exception:
        print("Could not show Growl success notification")


def notify_register():
    global gntp
    global growl

    if gntp is None:
        return

    try:
        growl = gntp.notifier.GrowlNotifier(
            applicationName='Rebuild daemon',
            notifications=('success', 'error'),
            defaultNotifications=('success', 'error')
        )
        growl.register()
    except Exception:
        print("Could not connect to Growl, you won't see notifications")
        gntp = None


def notify_success():
    if gntp is None:
        return

    try:
        growl.notify(
            noteType='success',
            title='Build succeeded',
            description='',
            icon='http://i.imgur.com/TBvmb.png',
            sticky=False,
            priority=-1,
        )
    except Exception:
        print("Could not show Growl success notification")


def rebuild():
    try:
        print("%s: Rebuilding..." % format_date(time.time()))
        command_line = ["brunch.cmd" if os.name == "nt" else "brunch",
                        "b",
                        "--config",
                        get_target_specific_config_filename(target)]
        if not debug:
            command_line.append("-m")

        try:
            proc = Popen(command_line,
                         cwd=os.path.join(cwd, "src"))
        except OSError as e:
            if e.errno == 2:
                raise Exception("Brunch not installed? (npm install -g brunch)")
            raise

        proc.communicate()

        if proc.returncode != 0:
            raise Exception("Brunch failed with return value %d, see errors above" % proc.returncode)

        if os.path.getsize(os.path.join(cwd, "src", "public", "javascripts", "vendor.js")) < 200000:
            print("Error: That weird bug happened again! (TODO: check why Brunch is creating an incomplete vendor.js file)",
                  file=sys.stderr)
            sys.exit(2)

        if target == "android":
            copy_build_output_to_android_project()
        elif target == "ios":
            copy_build_output_to_ios_project()
        elif target == "web":
            copy_build_output_to_web_project()
        else:
            raise AssertionError()
    except Exception as e:
        notify_error()
        print("%s: Failed to rebuild: %s" % (format_date(time.time()), e))
        return False
    except:
        print("%s: Quitting, rebuild might be inconsistent" % format_date(time.time()))
        raise
    else:
        notify_success()
        print("%s: Finished rebuilding" % format_date(time.time()))
        return True


try:
    notify_register()

    script_dir = re.sub(r'[\\/]?$', re.escape(os.sep), os.path.dirname(__file__))

    def filename_filter(filename):
        # filename is absolute, make it relative
        if not filename.startswith(script_dir):
            raise AssertionError

        filename = filename[len(script_dir):]

        return (not filename.startswith(os.path.join("src", "public", "")) and
                not filename.startswith(os.path.join("src", "node_modules", "")))

    create_target_specific_config_files()

    class EventHandler(watchdog.events.FileSystemEventHandler):
        def __init__(self, on_change_event):
            super(watchdog.events.FileSystemEventHandler, self).__init__()

            self._on_change_event = on_change_event

        def on_any_event(self, event):
            if event.is_directory or not filename_filter(event.src_path):
                return

            #print('Changed %s' % event.src_path)
            self._on_change_event.set()

    def rebuild_thread(event):
        force_rebuild = True
        last_force_rebuild_attempt = -999999

        while True:
            if force_rebuild:
                if time.time() - last_force_rebuild_attempt < 10:
                    if not event.wait(1):
                        continue
                # else rebuild now
            else:
                event.wait()
                event.clear()

                # Triggered by file change, wait a bit longer because multiple files might be changed at once
                while event.wait(0.125):
                    event.clear()

            if rebuild():
                force_rebuild = False
            else:
                force_rebuild = True
                last_force_rebuild_attempt = time.time()

    on_change_event = threading.Event()
    thread = threading.Thread(target=rebuild_thread, args=(on_change_event,))
    thread.daemon = True
    thread.start()

    event_handler = EventHandler(on_change_event)
    observer = watchdog.observers.Observer()
    observer.schedule(event_handler, path='src', recursive=True)
    observer.schedule(event_handler, path='extra_assets', recursive=True)
    observer.schedule(event_handler, path='i18n', recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1.5)
    except KeyboardInterrupt:
        print('\nQuit by user.')
    finally:
        observer.stop()
        observer.join()
except KeyboardInterrupt:
    print("\nQuit by user.")
