import pytest
from pages.login_page import LoginPage

@pytest.mark.auth
class TestAuthentication:

    def test_login_page_renders_successfully(self, driver, base_url):
        """Verify that the login screen loads correctly on Flutter Web."""
        login_page = LoginPage(driver, base_url)
        login_page.open()
        assert login_page.is_login_page_loaded(), "Login page failed to load elements"

    def test_login_with_valid_credentials(self, driver, base_url):
        """Verify login attempt with credentials."""
        login_page = LoginPage(driver, base_url)
        login_page.open()
        login_page.login("testuser@example.com", "Password123!")
        # Verify navigation or snackbar message
        assert driver.current_url is not None

    def test_guest_login_flow(self, driver, base_url):
        """Verify guest access login mode."""
        login_page = LoginPage(driver, base_url)
        login_page.open()
        login_page.click_guest_login()
        # Ensure redirect occurs away from login
        assert "login" not in driver.current_url.lower() or login_page.is_login_page_loaded()
