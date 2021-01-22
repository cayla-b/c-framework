import toolchain_utils
import string
import random
import subprocess
import unittest
import tempfile
import shutil
import os.path

""" Test the root Makefile """
class TestMakefileObjs(toolchain_utils.TestCFrameworkToolchainTestCase):

    def test_makeTest1(self):
        """ Check that build from src folder works correctly """
        buildNotGeneratedTest = [
            'bin/yourProject'
        ]
        buildGeneratedTest = [
            'deps/test1.d',
            'deps/module/test2.d',
            'include/test1.h',
            'include/config.h',
            'include/module/test2.h',
            'objs/test1.o',
            'objs/module/test2.o'
        ]
        try:
            makeHelpExecution = subprocess.run(\
                ['make', 'all'], \
                stdout=subprocess.DEVNULL, \
                stderr=subprocess.DEVNULL, \
                cwd=self.tempSrcDir, \
                timeout=10, check=True\
            )
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")
        
        for files in buildGeneratedTest:
            filesPath = os.path.join(self.tempBuildDir, files)
            self.assertTrue(os.path.exists(filesPath), filesPath + " not generated !")
            
        for files in buildNotGeneratedTest:
            filesPath = os.path.join(self.tempBuildDir, files)
            self.assertFalse(os.path.exists(filesPath), filesPath + " generated !")
        

    def test_makeTest2(self):
        """ Check that build from module folder works correctly """
        buildNotGeneratedTest = [
            'bin/yourProject',
            'deps/test1.d',
            'include/test1.h',
            'include/config.h',
            'objs/test1.o',
        ]
        buildGeneratedTest = [
            'deps/module/test2.d',
            'include/module/test2.h',
            'objs/module/test2.o'
        ]
        try:
            makeHelpExecution = subprocess.run(\
                ['make', 'all'], \
                stdout=subprocess.DEVNULL, \
                stderr=subprocess.DEVNULL, \
                cwd=self.tempSrcModuleDir, \
                timeout=10, check=True\
            )
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")
        
        for files in buildGeneratedTest:
            filesPath = os.path.join(self.tempBuildDir, files)
            self.assertTrue(os.path.exists(filesPath), filesPath + " not generated !")
            
        for files in buildNotGeneratedTest:
            filesPath = os.path.join(self.tempBuildDir, files)
            self.assertFalse(os.path.exists(filesPath), filesPath + " generated !")

if __name__ == '__main__':
    unittest.main()