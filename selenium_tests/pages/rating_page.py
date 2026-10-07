import time
from selenium.webdriver.common.by import By
from pages.base_page import BasePage

class RatingPage(BasePage):
    # Locators for Rating Screen
    REVIEW_TEXTAREA = (By.XPATH, "//textarea | //input[contains(@aria-label, 'Review') or contains(@aria-label, 'রিভিউ') or contains(@placeholder, 'return process')]")
    SUBMIT_RATING_BUTTON = (By.XPATH, "//*[contains(text(), 'Submit Rating') or contains(text(), 'রেটিং জমা দিন') or contains(text(), 'Submit') or contains(@aria-label, 'Submit Rating')]")
    STAR_RATING_FIVE = (By.XPATH, "//*[contains(@aria-label, '5 Star') or contains(@aria-label, '5') or contains(text(), '5 Stars') or contains(text(), '৫')]")
    SUCCESS_SNACKBAR = (By.XPATH, "//*[contains(text(), 'Thank you') or contains(text(), 'ধন্যবাদ')]")

    def open_claim_rating(self, claim_id="1"):
        self.navigate_to(f"/rating/{claim_id}")

    def enter_review_text(self, review_text):
        if self.is_element_present(*self.REVIEW_TEXTAREA, timeout=5):
            self.type_text(*self.REVIEW_TEXTAREA, review_text)

    def select_five_star_rating(self):
        if self.is_element_present(*self.STAR_RATING_FIVE, timeout=5):
            self.click(*self.STAR_RATING_FIVE)

    def click_submit_rating(self):
        if self.is_element_present(*self.SUBMIT_RATING_BUTTON, timeout=5):
            self.click(*self.SUBMIT_RATING_BUTTON)

    def submit_rating(self, review_text="Great experience recovering item!"):
        self.select_five_star_rating()
        self.enter_review_text(review_text)
        self.click_submit_rating()

    def is_submission_successful(self):
        return self.wait_for_snack_bar("Thank you") or self.wait_for_snack_bar("ধন্যবাদ")

