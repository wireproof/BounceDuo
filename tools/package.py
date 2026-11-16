from pathlib import Path
import zipfile,plistlib,hashlib,json
r=Path(__file__).resolve().parents[1]
a=r/'build/Build/Products/Release-iphoneos/Bounce.app'
p=plistlib.loads((a/'Info.plist').read_bytes())
assert p['CFBundleIdentifier']=='com.wireproof.bounce'
assert p['UIApplicationSceneManifest']['UISceneConfigurations']['UIWindowSceneSessionRoleApplication'][0]['UISceneDelegateClassName']=='BounceSceneDelegate'
assert p['CFBundleShortVersionString']=='0.1.8'
f=r/'dist'/f"{p['CFBundleIdentifier']}-{p['CFBundleShortVersionString']}-{p['CFBundleVersion']}.ipa"
with zipfile.ZipFile(f,'w',zipfile.ZIP_DEFLATED) as z:
 for src in sorted(a.rglob('*')):
  if src.is_file():z.write(src,'Payload/Bounce.app/'+str(src.relative_to(a)))
with zipfile.ZipFile(f) as z:assert z.testzip() is None
report={'bundle':p['CFBundleIdentifier'],'version':p['CFBundleShortVersionString'],'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'bytes':f.stat().st_size,'zipIntegrity':True,'deviceRuntimeTested':False}
(r/'docs/package.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
