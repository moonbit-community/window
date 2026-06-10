const fs = require("fs");
const path = require("path");

function readModuleName() {
  const moonModPath = path.join(__dirname, "moon.mod");
  if (fs.existsSync(moonModPath)) {
    const source = fs.readFileSync(moonModPath, "utf8");
    const match = source.match(/^name\s*=\s*"([^"]+)"/m);
    if (match !== null) {
      return match[1];
    }
  }

  const legacyConfigPath = path.join(__dirname, "moon.mod.json");
  const legacyConfig = JSON.parse(fs.readFileSync(legacyConfigPath, "utf8"));
  return legacyConfig.name;
}

const moduleName = readModuleName();
const macosPackageName = `${moduleName}/macos`;
const examplesUtilPackageName = `${moduleName}/examples/util`;
const macosFrameworkFlags =
  "-framework AppKit -framework Foundation -framework CoreGraphics -framework CoreVideo -framework ApplicationServices -lobjc";

console.log(
  JSON.stringify({
    link_configs: [
      {
        package: macosPackageName,
        link_flags: macosFrameworkFlags,
      },
      {
        package: examplesUtilPackageName,
        link_flags: macosFrameworkFlags,
      },
    ],
  }),
);
