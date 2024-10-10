#! /usr/bin/env python3

from collections import OrderedDict
import functools
import hashlib
import json
import os
import re
import requests

# output file
DEPENDENCIES_JSON = 'metadata/dependencies.json'

# input files
ANDROID_LICENSES = 'build/android_licenses.json'
FLUTTER_LICENSES = 'build/flutter_licenses.json'

# hard-coded license urls
LICENSE_URLS = {
    'The MIT License': 'https://spdx.org/licenses/MIT.txt',
    'MIT': 'https://spdx.org/licenses/MIT.txt',
}

# hard-coded additional dependencies
EXTRA_DEPS = {
    'Roc Toolkit': 'https://raw.githubusercontent.com/roc-streaming/roc-toolkit/HEAD/LICENSE',
    # Roc Toolkit dependencies:
    # see https://roc-streaming.org/toolkit/docs/building/dependencies.html
    'Hedley': 'https://raw.githubusercontent.com/nemequ/hedley/HEAD/COPYING',
    'OpenFEC': 'https://raw.githubusercontent.com/roc-streaming/openfec/HEAD/Licence_CeCILL_V2-en.txt',
    'OpenSSL': 'https://raw.githubusercontent.com/openssl/openssl/HEAD/LICENSE.txt',
    'SpeexDSP': 'https://raw.githubusercontent.com/xiph/speexdsp/HEAD/COPYING',
    'dr_wav': 'https://raw.githubusercontent.com/mackron/dr_libs/HEAD/LICENSE',
    'libuv': 'https://raw.githubusercontent.com/libuv/libuv/HEAD/LICENSE',
    'libuv-extra': 'https://raw.githubusercontent.com/libuv/libuv/HEAD/LICENSE-extra',
}

@functools.cache
def load_document(url):
    resp = requests.get(url)
    resp.raise_for_status()
    return resp.text

def android_license(dep):
    license_name = dep.get('moduleLicense', '')
    license_url = dep.get('moduleLicenseUrl', '')
    project_name = dep.get('moduleName', '')
    project_url = dep.get('moduleUrl', '')

    m = re.match(r'^https://github.com/(.+)$', project_url)
    if m:
        github_url = f'https://raw.githubusercontent.com/{m.group(1)}/HEAD/LICENSE'
        try:
            return load_document(github_url)
        except:
            pass

    m = re.match(r'^https://spdx.org/licenses/(.+).html$', license_url)
    if m:
        license_url = re.sub(r'.html$', '.txt', license_url)

    if license_url:
        try:
            return load_document(license_url)
        except:
            pass

    if license_name in LICENSE_URLS:
        license_url = LICENSE_URLS[license_name]
        try:
            return load_document(license_url)
        except:
            pass

    print(f'unable to locate license for {project_name}')
    exit(1)

def collect_android_dependencies():
    print(f'Processing {ANDROID_LICENSES} ...')

    result_deps = []

    with open(ANDROID_LICENSES) as fp:
        android_deps = json.load(fp)

    for dep in android_deps['dependencies']:
        skip = False
        for key in ['moduleName', 'moduleLicense']:
            if not key in dep:
                skip = True
                break
        if skip:
            continue

        result_deps.append({
            'name': dep['moduleName'],
            'platform': 'android',
            'license': android_license(dep),
        })

    return result_deps

def collect_flutter_dependencies():
    print(f'Processing {FLUTTER_LICENSES} ...')

    result_deps = []

    with open(FLUTTER_LICENSES) as fp:
        flutter_deps = json.load(fp)

    for dep in flutter_deps:
        result_deps.append({
            'name': dep['name'],
            'platform': 'all',
            'license': dep['license'],
        })

    return result_deps

def collect_extra_dependencies():
    print('Processing extra dependencies ...')

    result_deps = []

    for name, url in EXTRA_DEPS.items():
        result_deps.append({
            'name': name,
            'platform': 'all',
            'license': load_document(url),
        })

    return result_deps

def dump_json(dependencies):
    print(f'Generating {DEPENDENCIES_JSON} ...')

    report = {
        'dependencies': [],
        'licenses': {},
    }

    for dep in dependencies:
        license_text = dep['license'].lstrip('\n').rstrip('\n')
        license_id = hashlib.md5(license_text.encode()).hexdigest()

        report['licenses'][license_id] = license_text
        report['dependencies'].append(OrderedDict({
            'name': dep['name'],
            'platform': dep['platform'],
            'license': license_id,
        }))

    with open(DEPENDENCIES_JSON, 'w') as fp:
        json.dump(report, fp, indent=2)

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

dependencies = []
dependencies += collect_android_dependencies()
dependencies += collect_flutter_dependencies()
dependencies += collect_extra_dependencies()

dump_json(dependencies)
