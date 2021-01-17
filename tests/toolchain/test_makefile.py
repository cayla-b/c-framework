import toolchain_utils
import string
import random
import subprocess
import unittest

""" Test the root Makefile """
class TestMakefile(toolchain_utils.TestCFrameworkToolchainTestCase):

    def test_makeAllExists(self):
        """ Check that all target exists as a general target rules """
        try:
            makeHelpExecution = subprocess.run(['make', 'all'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

    def test_makeBinExists(self):
        """ Check that bin target exists as general target rules """
        try:
            makeHelpExecution = subprocess.run(['make', 'bin'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

    def test_makeTestExists(self):
        """ Check that test target exists as general target rules (except Toolchain test) """
        try:
            makeHelpExecution = subprocess.run(['make', 'test'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

    def test_makeCleanExists(self):
        """ Check that clean target exists as general target rules """
        try:
            makeHelpExecution = subprocess.run(['make', 'clean'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

    def test_makeDistcleanExists(self):
        """ Check that distclean target exists as general target rules """
        try:
            makeHelpExecution = subprocess.run(['make', 'distclean'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

    def test_makeHelpExists(self):
        """ Check that help target exist as a general target rules """
        try:
            makeHelpExecution = subprocess.run(['make', 'help'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

    def test_makeToolVerExists(self):
        """ Check that tools_ver target exist as a general target rules """
        try:
            makeHelpExecution = subprocess.run(['make', 'tools_ver'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
        except subprocess.TimeoutExpired as timeout_error:
            self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
        except subprocess.CalledProcessError as process_error:
            self.fail("Error calling " + ' '.join(process_error.cmd) + ": Invalid error code [" + str(process_error.returncode) + "]")

    def test_makeNoOtherRules(self):
        """ Check that no other target rules make the system react """
        excluded_pattern = ["all", "bin", "test", "clean", "disclean", "help", "tools_ver"]
        authorized_char = "".join([string.ascii_letters, string.digits, '\\', '/'])
        random.seed()
        for i in range(20):
            # Generate a random rule composed of ascii character, digits, / and \
            random_rule = "".join([random.choice(authorized_char) for i in range(random.randint(1, 50))])
            # Exclude pattern known to be valid
            if random_rule not in excluded_pattern:
                try:
                    makeHelpExecution = subprocess.run(['make', random_rule], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=self.tempDir.name, timeout=10, check=True)
                except subprocess.TimeoutExpired as timeout_error:
                    self.fail("Error calling " + ' '.join(timeout_error.cmd) + ": Timeout reached after " + str(timeout_error.timeout) + "s")
                except subprocess.CalledProcessError:
                    None # An error is expected when calling make with a random rule
                else:
                    self.fail("Error unexpected reaction calling make " + random_rule + " on folder named " + self.tempDir.name)

if __name__ == '__main__':
    unittest.main()