from selenium.webdriver.common.by import By
from pages.base_page import BasePage

class PostPage(BasePage):
    # Locators for Create Lost/Found Post Screen
    CREATE_HEADER = (By.XPATH, "//*[contains(text(), 'Report Lost or Found') or contains(text(), 'create_report') or contains(text(), 'রিপোর্ট')]")
    TITLE_INPUT = (By.XPATH, "//input[contains(@aria-label, 'Title') or contains(@aria-label, 'শিরোনাম') or contains(@placeholder, 'Title')]")
    CATEGORY_DROPDOWN = (By.XPATH, "//div[contains(@role, 'button') or contains(@aria-label, 'Category')] | //select")
    DESC_INPUT = (By.XPATH, "//textarea | //input[contains(@aria-label, 'Description') or contains(@aria-label, 'বিবরণ')]")
    LOCATION_INPUT = (By.XPATH, "//input[contains(@aria-label, 'Location') or contains(@aria-label, 'স্থান')]")
    PREVIEW_BUTTON = (By.XPATH, "//*[contains(text(), 'Preview & Publish') or contains(text(), 'প্রিভিউ') or contains(@aria-label, 'Preview')]")
    
    # Locators for Item Details Screen
    ITEM_TITLE = (By.XPATH, "//*[contains(@class, 'title') or contains(text(), 'Details')]")
    CLAIM_BUTTON = (By.XPATH, "//*[contains(text(), 'Claim This Item') or contains(text(), 'দাবি করুন') or contains(@aria-label, 'Claim')]")

    def open_create_post(self):
        self.navigate_to("/create-post-step1")

    def open_item_details(self, post_id="1"):
        self.navigate_to(f"/item-details/{post_id}")

    def enter_title(self, title):
        if self.is_element_present(*self.TITLE_INPUT, timeout=5):
            self.type_text(*self.TITLE_INPUT, title)

    def enter_description(self, desc):
        if self.is_element_present(*self.DESC_INPUT, timeout=5):
            self.type_text(*self.DESC_INPUT, desc)

    def enter_location(self, location):
        if self.is_element_present(*self.LOCATION_INPUT, timeout=5):
            self.type_text(*self.LOCATION_INPUT, location)

    def click_preview(self):
        if self.is_element_present(*self.PREVIEW_BUTTON, timeout=5):
            self.click(*self.PREVIEW_BUTTON)

    def create_lost_item_report(self, title="Lost iPhone 14 Pro", desc="Black color, lost near Dhanmondi 27", location="Dhanmondi, Dhaka"):
        self.enter_title(title)
        self.enter_description(desc)
        self.enter_location(location)
        self.click_preview()

    def click_claim_item(self):
        if self.is_element_present(*self.CLAIM_BUTTON, timeout=5):
            self.click(*self.CLAIM_BUTTON)

    def is_create_post_loaded(self):
        return (
            "create" in self.driver.current_url.lower() or
            self.is_element_present(*self.CREATE_HEADER, timeout=5) or
            self.is_element_present(*self.TITLE_INPUT, timeout=5) or
            self.is_element_present(*self.PREVIEW_BUTTON, timeout=5)
        )

