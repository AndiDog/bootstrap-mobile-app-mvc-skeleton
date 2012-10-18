from __future__ import print_function
try:
    input = raw_input
except NameError:
    pass
import os


def combine(*dicts):
    ret = {}
    for d in dicts:
        ret.update(d)
    return ret


def rename(path_elements, rename_to):
    replace(path_elements, replacements=None, rename_to=rename_to)


def replace(path_elements, replacements, rename_to=None):
    filename = os.path.join(project_dir, *path_elements)
    new_filename = os.path.join(project_dir, *rename_to) if rename_to is not None else None

    if replacements is not None:
        with open(filename, 'r+b') as f:
            content = f.read()
            for key, value in replacements.items():
                content = content.replace(key, value)

            f.seek(0)
            f.write(content)
            f.truncate()

    if new_filename is not None:
        if not os.path.isdir(os.path.dirname(new_filename)):
            os.makedirs(os.path.dirname(new_filename))

        os.rename(filename, new_filename)

        folder = os.path.dirname(filename)
        while folder != os.path.dirname(new_filename) and os.path.isdir(folder):
            try:
                os.rmdir(folder)
            except Exception:
                break


def replace_multi(multipath_elements, replacements):
    for path_elements in multipath_elements:
        replace(path_elements, replacements)


if __name__ == '__main__':
    project_dir = os.path.abspath(os.path.dirname(__file__))
    if not os.path.exists('Start rebuild daemon for browser testing.bat'):
        raise AssertionError

    print('Make sure you only run this once because this script assumes the project name "MobileSkeleton" everywhere.' +
          'If you made a mistake, reset the repository to its previous state, delete unversioned folders/files and ' +
          'run this script again.')
    print()

    project_name = input('Enter the project name without spaces as will be used for project filenames (e.g. ' +
                         '"MobileSkeleton", not the full product name): ').strip()
    if ' ' in project_name:
        raise AssertionError('Project name may not have spaces')

    product_name = input('Enter the product name as it should be shown on the iOS launcher, for example (e.g. ' +
                         '"Mobile Skeleton"): ').strip()

    android_lowercase = {'y': True,
                         'Y': True,
                         'n': False,
                         '': True}[input('Should the Android package name be lowercase (e.g. ' +
                                         'de.andidog.mobileskeleton instead of de.andidog.MobileSkeleton) ' +
                                         '[Yn]: ').strip()]

    ios_package_name = input('Enter the full package name for use with the iOS project (e.g. ' +
                             'de.andidog.MobileSkeleton): ').strip()

    android_package_name = ios_package_name.lower() if android_lowercase else ios_package_name

    print()
    print('Summary:')
    print('- Project name: %s' % project_name)
    print('- Product name: %s' % product_name)
    print('- Android package name: %s' % android_package_name)
    print('- iOS package name: %s' % ios_package_name)
    print()
    if not {'y': True, 'n': False}[input('Is that correct? [yn]: ').strip()]:
        raise Exception('User canceled')

    product_name_replacement = {'Mobile Skeleton': product_name}
    project_name_replacement = {'MobileSkeleton': project_name}
    android_package_replacement = {'de.andidog.mobileskeleton': android_package_name}
    ios_package_replacement = {'de.andidog.MobileSkeleton': ios_package_name}

    replace(['android', '.project'], project_name_replacement)
    replace(['android', 'src', 'de', 'andidog', 'mobileskeleton', 'MainActivity.java'],
            android_package_replacement,
            ['android', 'src'] + list(android_package_name.split('.')) + ['MainActivity.java'])
    replace(['android', 'AndroidManifest.xml'], android_package_replacement)
    replace(['dependencies', 'android', 'ActionBarSherlock', 'library', '.project'],
            {'k dependency</name>': 'k dependency for %s</name>' % project_name})
    replace(['android', '.externalToolBuilders', 'Force rebuild MobileSkeleton.launch'],
            project_name_replacement,
            ['android', '.externalToolBuilders', 'Force rebuild %s.launch' % project_name])
    replace(['android', 'res', 'values', 'strings.xml'],
            {'Mobile Skeleton App': product_name})

    replace(['ios', 'MobileSkeleton.xcodeproj', 'project.pbxproj'],
            {'product_name = MobileSkeleton;': 'product_name = "%s";' % product_name,
             'PRODUCT_NAME = MobileSkeleton;': 'PRODUCT_NAME = "%s";' % product_name})
    replace(['ios', 'MobileSkeleton.xcodeproj', 'project.pbxproj'], project_name_replacement)
    replace(['ios', 'MobileSkeleton.xcodeproj', 'project.xcworkspace', 'contents.xcworkspacedata'],
            project_name_replacement)
    replace(['ios', 'MobileSkeleton', 'main.m'], project_name_replacement)
    replace(['ios', 'MobileSkeleton', 'MobileSkeleton-Info.plist'],
            ios_package_replacement,
            ['ios', 'MobileSkeleton', '%s-Info.plist' % project_name])
    replace(['ios', 'MobileSkeleton', 'MobileSkeleton-Prefix.pch'],
            project_name_replacement,
            ['ios', 'MobileSkeleton', '%s-Prefix.pch' % project_name])
    replace_multi(
        [
            ['ios', 'MobileSkeleton', 'Classes', 'AppDelegate.h'],
            ['ios', 'MobileSkeleton', 'Classes', 'AppDelegate.m'],
            ['ios', 'MobileSkeleton', 'Classes', 'MainViewController.h'],
            ['ios', 'MobileSkeleton', 'Classes', 'MainViewController.m']
        ],
        project_name_replacement)
    replace(['src', 'app', 'application.coffee'],
            {'<a class="brand">MobileSkeleton</a>': '<a class="brand">%s</a>' % project_name})

    rename(['ios', 'MobileSkeleton.xcodeproj'], ['ios', '%s.xcodeproj' % project_name])
    rename(['ios', 'MobileSkeleton'], ['ios', project_name])

    print('Done renaming projects.')