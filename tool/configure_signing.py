from pathlib import Path
import os

root = Path(__file__).resolve().parents[1]
app = root / 'android' / 'app'
keystore = app / 'bazaar-release.jks'

data = os.environ.get('BAZAAR_KEYSTORE_BASE64')
if not data:
    print('No BAZAAR_KEYSTORE_BASE64 secret supplied; leaving Flutter default release signing in place.')
    raise SystemExit(0)

import base64
keystore.write_bytes(base64.b64decode(data))
path_for_gradle = keystore.as_posix()
password = os.environ['BAZAAR_KEYSTORE_PASSWORD']
alias = os.environ['BAZAAR_KEY_ALIAS']
key_password = os.environ['BAZAAR_KEY_PASSWORD']

gradle = next((p for p in [app / 'build.gradle.kts', app / 'build.gradle'] if p.exists()), None)
if gradle is None:
    raise SystemExit('Android app Gradle file not found')
g = gradle.read_text(encoding='utf-8')

if gradle.name.endswith('.kts'):
    block = f'''\n    signingConfigs {{\n        create("release") {{\n            storeFile = file("{path_for_gradle}")\n            storePassword = System.getenv("BAZAAR_KEYSTORE_PASSWORD")\n            keyAlias = System.getenv("BAZAAR_KEY_ALIAS")\n            keyPassword = System.getenv("BAZAAR_KEY_PASSWORD")\n        }}\n    }}\n'''
    if 'create("release")' not in g:
        g = g.replace('    buildTypes {', block + '    buildTypes {', 1)
    g = g.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")', 1)
    if 'signingConfig = signingConfigs.getByName("release")' not in g:
        g = g.replace('release {', 'release {\n            signingConfig = signingConfigs.getByName("release")', 1)
else:
    block = f'''\n    signingConfigs {{\n        release {{\n            storeFile file("{path_for_gradle}")\n            storePassword System.getenv("BAZAAR_KEYSTORE_PASSWORD")\n            keyAlias System.getenv("BAZAAR_KEY_ALIAS")\n            keyPassword System.getenv("BAZAAR_KEY_PASSWORD")\n        }}\n    }}\n'''
    if 'release {' not in g[g.find('signingConfigs'):g.find('signingConfigs') + 500]:
        g = g.replace('    buildTypes {', block + '    buildTypes {', 1)
    g = g.replace('signingConfig signingConfigs.debug', 'signingConfig signingConfigs.release', 1)
    if 'signingConfig signingConfigs.release' not in g:
        g = g.replace('release {', 'release {\n            signingConfig signingConfigs.release', 1)

gradle.write_text(g, encoding='utf-8')
print('Configured Bazaar release signing from GitHub Actions secrets.')
