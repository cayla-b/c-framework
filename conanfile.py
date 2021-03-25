from conans import ConanFile, CMake, tools


class CFrameworkConan(ConanFile):
    name = "c-framework"
    version = "1.0"
    license = "MIT"
    author = "Bertrand CAYLA cayla.bertrand@laposte.net"
    url = "https://github.com/cayla-b/c-framework"
    description = "C Framework"
    topics = ("<Put some tag here>", "<here>", "<and here>")
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}
    generators = "make"

    def source(self):
        self.run("git clone https://github.com/conan-io/hello.git")

    def build(self):
        self.run("make all")

    def package(self):
        self.copy("*.h", dst="include", src="src")
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["c-framework"]

