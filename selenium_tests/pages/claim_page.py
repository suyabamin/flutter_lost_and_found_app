from selenium.webdriver.common.by import By
from pages.base_page import BasePage

class ClaimPage(BasePage):
    # Locators for Submit Claim Screen
    CLAIM_HEADER = (By.XPATH, "//*[contains(text(), 'Submit Claim') or contains(text(), 'দাবি জমা দিন')]")
    PROOF_DESCRIPTION = (By.XPATH, "//textarea | //input[contains(@aria-label, 'Proof') or contains(@aria-label, 'প্রমাণ') or contains(@placeholder, 'proof')]")
    SUBMIT_CLAIM_BUTTON = (By.XPATH, "//*[contains(text(), 'Submit Claim') or contains(text(), 'দাবি পেশ করুন') or contains(@aria-label, 'Submit')]")

    # Locators for Claim Details / Recovery Completed Screen
    RECOVERY_HEADER = (By.XPATH, "//*[contains(text(), 'Recovery Completed') or contains(text(), 'আইটেম উদ্ধার সম্পন্ন')]")
    PROCEED_RATING_BUTTON = (By.XPATH, "//*[contains(text(), 'Rate User') or contains(text(), 'রেটিং দিন') or contains(text(), 'Leave Review')]")

    def open_submit_claim(self, post_id="1"):
        self.navigate_to(f"/submit-claim/{post_id}")

    def open_claim_details(self, claim_id="1"):
        self.navigate_to(f"/claim-details/{claim_id}")

    def open_recovery_completed(self, claim_id="1"):
        self.navigate_to(f"/recovery-completed/{claim_id}")

    def enter_proof_details(self, proof_text="I have the original purchase receipt and serial number matching the device."):
        if self.is_element_present(*self.PROOF_DESCRIPTION, timeout=5):
            self.type_text(*self.PROOF_DESCRIPTION, proof_text)

    def submit_claim(self, proof_text="I have the original purchase receipt and serial number."):
        self.enter_proof_details(proof_text)
        if self.is_element_present(*self.SUBMIT_CLAIM_BUTTON, timeout=5):
            self.click(*self.SUBMIT_CLAIM_BUTTON)

    def click_rate_user(self):
        if self.is_element_present(*self.PROCEED_RATING_BUTTON, timeout=5):
            self.click(*self.PROCEED_RATING_BUTTON)

    def is_submit_claim_loaded(self):
        return (
            "claim" in self.driver.current_url.lower() or
            self.is_element_present(*self.CLAIM_HEADER, timeout=5) or
            self.is_element_present(*self.SUBMIT_CLAIM_BUTTON, timeout=5)
        )

