import sys
import os
import os.path
import traceback
import tempfile
import shutil
import zipfile
import unittest

""" Parent Class for all toolchain test """
class TestCFrameworkToolchainTestCase(unittest.TestCase):
    min_python_major = 3
    min_python_minor = 6
    python_major = sys.version_info.major
    python_minor = sys.version_info.minor

    @classmethod
    def setUpClass(cls):
        if (cls.python_major < cls.min_python_major) or ((cls.python_major == cls.min_python_major) and (cls.python_minor < cls.min_python_minor)):
            skipClassException = unittest.SkipTest(" : ".join([__file__, cls.__name__, "Python version < 3.6 (please update your python version)"]))
            raise(skipClassException)

    def _getGitRoot():
        """ Acquire this repository root (please feel free to propose improvement) """
        with os.popen("git rev-parse --show-toplevel") as git_root:
            git_root = os.path.abspath(git_root.readline().rstrip())
        return git_root

    def setUp(self):
        """ Prepare a dummy repository where to start testing toolchain """
        # Acquire the temporary directory and present repository root
        self.tempDir = tempfile.TemporaryDirectory(prefix="test_toolchain_")
        projectDir = TestCFrameworkToolchainTestCase._getGitRoot()

        # Copy the present dir to the temporary test dir
        for file in os.scandir(projectDir):
            if file.is_dir():
                shutil.copytree(file, os.path.join(self.tempDir.name, os.path.basename(file.name)))
            else:
                shutil.copy2(file, os.path.join(self.tempDir.name, os.path.basename(file.name)))
        
        # Build useful temporary default subdir for test purpose
        # ???/assets
        self.tempAssetsDir = os.path.join(self.tempDir.name, "assets")
        # ???/build
        self.tempBuildDir = os.path.join(self.tempDir.name, "build")
        # ???/src
        self.tempSrcDir = os.path.join(self.tempDir.name, "src")
        self.tempSrcModuleDir = os.path.join(self.tempSrcDir, "module")
        # ???/tests
        self.tempTestsDir = os.path.join(self.tempDir.name, "tests")
        self.tempTestsAssetsDir = os.path.join(self.tempTestsDir, "assets")
        self.tempTestsProject = os.path.join(self.tempTestsDir, "project")
        self.tempTestsToolchainDir = os.path.join(self.tempTestsDir, "toolchain")
        # ???/tools
        self.tempToolsDir = os.path.join(self.tempDir.name, "tools")

        # Remove test/toolchain to avoid infinite recursion
        shutil.rmtree(self.tempTestsToolchainDir)

        # Replace src by directory extracted from tests/assets/dummy_src.zip
        shutil.rmtree(self.tempSrcDir)
        os.mkdir(self.tempSrcDir)
        default_src_archive_path = os.path.join(self.tempTestsAssetsDir, "dummy_src.zip")
        with zipfile.ZipFile(default_src_archive_path) as default_src_archive:
            default_src_archive.extractall(self.tempSrcDir)

        # Copy default Makefile in src and src/module folder for test purpose
        default_makefile_path = os.path.join(self.tempToolsDir, "default_Makefile")
        src_makefile_path = os.path.join(self.tempSrcDir, "Makefile")
        src_module_makefile_path = os.path.join(self.tempSrcModuleDir, "Makefile")
        shutil.copy2(default_makefile_path, src_makefile_path)
        shutil.copy2(default_makefile_path, src_module_makefile_path)

        # Execute package configurator to ensure /config.mk and /src/config.h exists
        default_configmk_path = os.path.join(self.tempTestsAssetsDir, "dummy_config.mk")
        configmk_path         = os.path.join(self.tempDir.name, "config.mk")
        default_configh_path  = os.path.join(self.tempTestsAssetsDir, "dummy_config.h")
        configh_path          = os.path.join(self.tempSrcDir, "config.h")
        shutil.copy2(default_configmk_path, configmk_path)
        shutil.copy2(default_configh_path, configh_path)
        

    def tearDown(self):
        """ Delete the temporary folder """
        self.tempDir.cleanup()
