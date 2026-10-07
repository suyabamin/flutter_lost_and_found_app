from selenium.webdriver.common.by import By
from pages.base_page import BasePage

class LoginPage(BasePage):
    # Locators for Flutter Web DOM / ARIA semantics
    EMAIL_INPUT = (By.XPATH, "//input[@type='email' or contains(@aria-label, 'Email') or contains(@aria-label, 'ইমেইল')]")
    PASSWORD_INPUT = (By.XPATH, "//input[@type='password' or contains(@aria-label, 'Password') or contains(@aria-label, 'পাসওয়ার্ড')]")
    LOGIN_BUTTON = (By.XPATH, "//*[contains(text(), 'Login') or contains(text(), 'লগইন') or contains(@aria-label, 'Login')]")
    GUEST_BUTTON = (By.XPATH, "//*[contains(text(), 'Guest') or contains(text(), 'গেস্ট') or contains(@aria-label, 'Guest')]")
    GOOGLE_BUTTON = (By.XPATH, "//*[contains(text(), 'Google') or contains(@aria-label, 'Google')]")
    REGISTER_LINK = (By.XPATH, "//*[contains(text(), 'Sign Up') or contains(text(), 'সাইন আপ') or contains(text(), 'Register')]")

    def open(self):
        self.navigate_to("/login")

    def enter_email(self, email):
        self.type_text(*self.EMAIL_INPUT, email)

    def enter_password(self, password):
        self.type_text(*self.PASSWORD_INPUT, password)

    def click_login(self):
        self.click(*self.LOGIN_BUTTON)

    def login(self, email, password):
        self.enter_email(email)
        self.enter_password(password)
        self.click_login()

    def click_guest_login(self):
        if self.is_element_present(*self.GUEST_BUTTON):
            self.click(*self.GUEST_BUTTON)

    def is_login_page_loaded(self):
        return self.is_element_present(*self.LOGIN_BUTTON) or self.is_element_present(*self.EMAIL_INPUT)
