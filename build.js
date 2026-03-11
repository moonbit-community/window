const os = require("os");

const platform = os.platform();
const macosFrameworkFlags =
  "-framework AppKit -framework Foundation -framework CoreGraphics -framework Carbon -lobjc";

const output = {
  link_configs: [],
};

if (platform === "darwin") {
  output.link_configs.push({
    package: "Milky2018/window/macos",
    link_flags: macosFrameworkFlags,
  });
}

console.log(JSON.stringify(output));
