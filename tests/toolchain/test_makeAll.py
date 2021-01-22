import toolchain_utils
import string
import random
import subprocess
import unittest
import tempfile
import shutil
import os.path

""" Test the root Makefile """
class TestMakefileAll(toolchain_utils.TestCFrameworkToolchainTestCase):

    buildGenerated = [
        'bin/yourProject',
        'deps/test1.d',
        'deps/module/test2.d',
        'include/test1.h',
        'include/config.h',
        'include/module/test2.h',
        'objs/test1.o',
        'objs/module/test2.o'
    ]

    def test_makeAll(self):
        """ Check that build from git root is valid """
        try:
            makeHelpExecution = subprocess.run(\
                ['make', 'all'], \
                stdout=subprocess.DEVNULL, \
                stderr=subprocess.DEVNULL, \
                cwd=self.tempDir.name, \
                timeout=10, check=True\
            )
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")
        
        for files in TestMakefileAll.buildGenerated:
            filesPath = os.path.join(self.tempBuildDir, files)
            self.assertTrue(os.path.exists(filesPath), filesPath + " not generated !")

    def test_makeAllToAnotherFolder(self):
        """ Check that build to another folder (BUILDDIR) is valid (git)"""
        try:
            makeHelpExecution = subprocess.run(\
                ['make','BUILDDIR=' + self.anotherTempDir.name,'all'], \
                stdout=subprocess.DEVNULL, \
                stderr=subprocess.DEVNULL, \
                cwd=self.tempDir.name, \
                timeout=10, check=True \
            )
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")
        
        for files in TestMakefileAll.buildGenerated:
            filesPath = os.path.join(self.anotherTempDir.name, files)
            self.assertTrue(os.path.exists(filesPath), filesPath + " not generated !")

    def test_makeAllFromAnotherFolder(self):
        """ Check that build from another folder is (-C options) valid (git)"""
        try:
            makeHelpExecution = subprocess.run(\
                ['make','-C',self.tempDir.name,'all'], \
                stdout=subprocess.DEVNULL, \
                stderr=subprocess.DEVNULL, \
                cwd=self.anotherTempDir.name, \
                timeout=10, check=True \
            )
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")
        
        for files in TestMakefileAll.buildGenerated:
            filesPath = os.path.join(self.tempBuildDir, files)
            self.assertTrue(os.path.exists(filesPath), filesPath + " not generated !")

    def test_makeAllFromAnotherToAnotherFolder(self):
        """ Check that build from another folder is (-C options) to another folder (BUILDDIR) valid (git) """
        try:
            makeHelpExecution = subprocess.run( \
                ['make','-C',self.tempDir.name,'BUILDDIR='+self.anotherTempDir.name,'all'], \
                stdout=subprocess.DEVNULL, \
                stderr=subprocess.DEVNULL, \
                cwd=self.anotherTempDir.name, \
                timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")
        
        for files in TestMakefileAll.buildGenerated:
            filesPath = os.path.join(self.anotherTempDir.name, files)
            self.assertTrue(os.path.exists(filesPath), filesPath + " not generated !")

    def test_makeAllNoGit(self):
        """ Check that build from a folder is valid  (non-git)"""
        shutil.rmtree(os.path.join(self.tempDir.name, '.git'))
        try:
            makeHelpExecution = subprocess.run(['make','all'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

        for files in TestMakefileAll.buildGenerated:
            filesPath = os.path.join(self.tempBuildDir, files)
            self.assertTrue(os.path.exists(filesPath), filesPath + " not generated !")

if __name__ == '__main__':
    unittest.main()