const fs = require("fs");
const path = require("path");

const moduleConfigPath = path.join(__dirname, "moon.mod.json");
const moduleConfig = JSON.parse(fs.readFileSync(moduleConfigPath, "utf8"));
const macosPackageName = `${moduleConfig.name}/macos`;
const examplesUtilPackageName = `${moduleConfig.name}/examples/util`;
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
