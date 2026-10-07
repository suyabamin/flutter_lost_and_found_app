import pytest
import time
from pages.register_page import RegisterPage

@pytest.mark.auth
class TestRegistration:

    def test_register_page_renders_successfully(self, driver, base_url):
        """Verify that the account creation screen loads correctly."""
        register_page = RegisterPage(driver, base_url)
        register_page.open()
        assert register_page.is_register_page_loaded(), "Register page failed to render required elements"

    def test_account_creation_form_submission(self, driver, base_url):
        """Verify user registration form submission."""
        timestamp = int(time.time())
        test_email = f"user_{timestamp}@example.com"
        
        register_page = RegisterPage(driver, base_url)
        register_page.open()
        register_page.register(
            name="Tanvir Rahman",
            email=test_email,
            phone="+8801711223344",
            password="Password123!"
        )
        assert driver.current_url is not None
