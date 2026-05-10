const fs = require("fs");
const path = require("path");

const moduleConfigPath = path.join(__dirname, "moon.mod.json");
const moduleConfig = JSON.parse(fs.readFileSync(moduleConfigPath, "utf8"));
const macosPackageName = `${moduleConfig.name}/macos`;
const windowsPackageName = `${moduleConfig.name}/windows`;
const examplesUtilPackageName = `${moduleConfig.name}/examples/util`;
const macosFrameworkFlags =
  "-framework AppKit -framework Foundation -framework CoreGraphics -framework CoreVideo -framework ApplicationServices -lobjc";
const windowsLibFlags =
  "-luser32 -lgdi32 -lkernel32 -lole32 -loleaut32 -lshell32 -ldwmapi -limm32 -lshcore";

const isWindows = process.platform === "win32";

const linkConfigs = [
  {
    package: macosPackageName,
    link_flags: macosFrameworkFlags,
  },
  {
    package: examplesUtilPackageName,
    link_flags: macosFrameworkFlags,
  },
];

if (isWindows) {
  linkConfigs.push({
    package: windowsPackageName,
    link_flags: windowsLibFlags,
  });
}

console.log(
  JSON.stringify({
    link_configs: linkConfigs,
  }),
);
