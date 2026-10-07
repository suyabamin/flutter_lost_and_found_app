from selenium.webdriver.common.by import By
from pages.base_page import BasePage

class RegisterPage(BasePage):
    # Locators for Register Screen
    HEADER = (By.XPATH, "//*[contains(text(), 'Create Account') or contains(text(), 'একাউন্ট তৈরি করুন')]")
    NAME_INPUT = (By.XPATH, "//input[contains(@aria-label, 'Full Name') or contains(@aria-label, 'নাম') or contains(@placeholder, 'Full Name') or contains(@placeholder, 'Tanvir')]")
    EMAIL_INPUT = (By.XPATH, "//input[@type='email' or contains(@aria-label, 'Email') or contains(@placeholder, 'example.com')]")
    PHONE_INPUT = (By.XPATH, "//input[@type='tel' or contains(@aria-label, 'Phone') or contains(@placeholder, '+880')]")
    PASSWORD_INPUT = (By.XPATH, "//input[@type='password' or contains(@aria-label, 'Password')]")
    CONFIRM_PASSWORD_INPUT = (By.XPATH, "(//input[@type='password' or contains(@aria-label, 'Password')])[2]")
    TERMS_CHECKBOX = (By.XPATH, "//input[@type='checkbox'] | //*[contains(@role, 'checkbox')]")
    REGISTER_BUTTON = (By.XPATH, "//*[contains(text(), 'Create Account') or contains(text(), 'Register Account') or contains(text(), 'একাউন্ট খুলুন') or contains(@aria-label, 'Register')]")
    LOGIN_LINK = (By.XPATH, "//*[contains(text(), 'Sign In') or contains(text(), 'লগইন করুন')]")

    def open(self):
        self.navigate_to("/register")

    def enter_full_name(self, name):
        if self.is_element_present(*self.NAME_INPUT, timeout=5):
            self.type_text(*self.NAME_INPUT, name)

    def enter_email(self, email):
        if self.is_element_present(*self.EMAIL_INPUT, timeout=5):
            self.type_text(*self.EMAIL_INPUT, email)

    def enter_phone(self, phone):
        if self.is_element_present(*self.PHONE_INPUT, timeout=5):
            self.type_text(*self.PHONE_INPUT, phone)

    def enter_password(self, password):
        if self.is_element_present(*self.PASSWORD_INPUT, timeout=5):
            self.type_text(*self.PASSWORD_INPUT, password)

    def enter_confirm_password(self, password):
        if self.is_element_present(*self.CONFIRM_PASSWORD_INPUT, timeout=5):
            self.type_text(*self.CONFIRM_PASSWORD_INPUT, password)

    def check_terms(self):
        if self.is_element_present(*self.TERMS_CHECKBOX, timeout=3):
            self.click(*self.TERMS_CHECKBOX)

    def click_register(self):
        if self.is_element_present(*self.REGISTER_BUTTON, timeout=5):
            self.click(*self.REGISTER_BUTTON)

    def register(self, name, email, phone, password):
        self.enter_full_name(name)
        self.enter_email(email)
        self.enter_phone(phone)
        self.enter_password(password)
        self.enter_confirm_password(password)
        self.check_terms()
        self.click_register()

    def is_register_page_loaded(self):
        return (
            "register" in self.driver.current_url.lower() or
            self.is_element_present(*self.HEADER, timeout=5) or
            self.is_element_present(*self.NAME_INPUT, timeout=5) or
            self.is_element_present(*self.EMAIL_INPUT, timeout=5)
        )

