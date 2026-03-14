const fs = require("fs");
const path = require("path");

const moduleConfigPath = path.join(__dirname, "moon.mod.json");
const moduleConfig = JSON.parse(fs.readFileSync(moduleConfigPath, "utf8"));
const packageName = `${moduleConfig.name}/macos`;
const macosFrameworkFlags =
  "-framework AppKit -framework Foundation -framework CoreGraphics -framework CoreVideo -framework ApplicationServices -lobjc";

console.log(
  JSON.stringify({
    link_configs: [
      {
        package: packageName,
        link_flags: macosFrameworkFlags,
      },
    ],
  }),
);
