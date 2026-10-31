from pathlib import Path
import plistlib
r=Path(__file__).resolve().parents[1]
p=r/'ios/Bounce/Bounce-Info.plist'
d=plistlib.loads(p.read_bytes())
d['UIApplicationSceneManifest']={'UIApplicationSupportsMultipleScenes':False,'UISceneConfigurations':{'UIWindowSceneSessionRoleApplication':[{'UISceneConfigurationName':'Bounce','UISceneDelegateClassName':'BounceSceneDelegate'}]}}
p.write_bytes(plistlib.dumps(d))
p=r/'ios/Bounce.xcodeproj/project.pbxproj';s=p.read_text().replace('dummy.cpp','dummy.mm').replace('sourcecode.cpp.cpp','sourcecode.cpp.objcpp');p.write_text(s)
src=r/'ios/Bounce/dummy.cpp';dest=r/'ios/Bounce/dummy.mm'
if src.exists():
 dest.write_text(src.read_text()+'\n'+(r/'native/BounceSceneDelegate.mm').read_text());src.unlink()
