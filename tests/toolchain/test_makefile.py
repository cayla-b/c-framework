import toolchain_utils
import unittest

""" Test the root Makefile """
class TestMakefile(toolchain_utils.TestCFrameworkToolchainTestCase):

    def test_makeHelpExists(self):
        """ Check that help target exist as a general target rules """

    def test_makeAllExists(self):
        """ Check that all target exists as a general target rules """

    def test_makeBinExists(self):
        """ Check that bin target exists as general target rules """

    def test_makeTestExists(self):
        """ Check that test target exists as general target rules (except Toolchain test) """

    def test_makeCleanExists(self):
        """ Check that clean target exists as general target rules """

    def test_makeDistcleanExists(self):
        """ Check that distclean target exists as general target rules """
        import os
        print(os.listdir(self.tempDir.name))
        print(os.listdir(self.tempSrcDir))
        print(os.listdir(self.tempSrcModuleDir))

if __name__ == '__main__':
    unittest.main()