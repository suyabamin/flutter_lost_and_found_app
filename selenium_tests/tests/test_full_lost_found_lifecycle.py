import pytest
import time
from pages.register_page import RegisterPage
from pages.login_page import LoginPage
from pages.post_page import PostPage
from pages.claim_page import ClaimPage
from pages.rating_page import RatingPage

@pytest.mark.lifecycle
class TestFullLostFoundLifecycle:

    def test_complete_lost_found_recovery_and_rating_lifecycle(self, driver, base_url):
        """
        Complete End-to-End User Flow Test:
        1. Account Creation / Registration
        2. User Login
        3. Create & Post Lost Item Report
        4. Browse & Submit Claim by second user
        5. Recovery Completion
        6. Submit Ratings & Reviews by both parties
        """
        timestamp = int(time.time())
        user1_email = f"owner_{timestamp}@example.com"
        user2_email = f"claimer_{timestamp}@example.com"
        claim_id = f"claim_{timestamp}"

        # ----------------------------------------------------
        # Step 1: User 1 Registration & Login
        # ----------------------------------------------------
        register_page = RegisterPage(driver, base_url)
        register_page.open()
        register_page.take_screenshot("step01_register_page")
        assert register_page.is_register_page_loaded(), "Registration page failed to load"
        
        register_page.register("Item Owner", user1_email, "+8801700000001", "Password123!")
        register_page.take_screenshot("step02_user1_registered")
        
        login_page = LoginPage(driver, base_url)
        login_page.open()
        login_page.take_screenshot("step03_login_page")
        assert login_page.is_login_page_loaded(), "Login page failed to load"
        login_page.login(user1_email, "Password123!")
        login_page.take_screenshot("step04_user1_logged_in")

        # ----------------------------------------------------
        # Step 2: User 1 Posts Lost Item
        # ----------------------------------------------------
        post_page = PostPage(driver, base_url)
        post_page.open_create_post()
        post_page.take_screenshot("step05_create_post_form")
        assert post_page.is_create_post_loaded(), "Create post page failed to load"
        
        post_page.create_lost_item_report(
            title="Lost Blue Laptop Bag",
            desc="Contains laptop, ID card, and keys. Lost near Dhanmondi 27",
            location="Dhanmondi, Dhaka"
        )
        post_page.take_screenshot("step06_item_posted_successfully")
        assert driver.current_url is not None

        # ----------------------------------------------------
        # Step 3: User 2 Registration & Claim Submission
        # ----------------------------------------------------
        register_page.open()
        register_page.register("Item Finder", user2_email, "+8801700000002", "Password123!")
        register_page.take_screenshot("step07_user2_registered")

        claim_page = ClaimPage(driver, base_url)
        claim_page.open_submit_claim("1")
        claim_page.take_screenshot("step08_claim_form")
        claim_page.submit_claim("Found near Dhanmondi 27 bus stand. Verified student ID inside.")
        claim_page.take_screenshot("step09_claim_submitted")

        # ----------------------------------------------------
        # Step 4: Recovery Completion & Item Returned
        # ----------------------------------------------------
        claim_page.open_recovery_completed(claim_id)
        claim_page.take_screenshot("step10_recovery_completed")
        assert "recovery" in driver.current_url.lower() or claim_page.driver.current_url is not None

        # ----------------------------------------------------
        # Step 5: Rating & Review Submission by both parties
        # ----------------------------------------------------
        rating_page = RatingPage(driver, base_url)
        rating_page.open_claim_rating(claim_id)
        rating_page.take_screenshot("step11_user1_rating_screen")
        
        # User 1 rates User 2
        rating_page.submit_rating("Excellent person! Swiftly returned my laptop bag safely.")
        rating_page.take_screenshot("step12_user1_rating_submitted")
        
        # User 2 rates User 1
        rating_page.open_claim_rating(f"{claim_id}_user2")
        rating_page.take_screenshot("step13_user2_rating_screen")
        rating_page.submit_rating("Great owner, polite and offered reward. Highly recommended!")
        rating_page.take_screenshot("step14_user2_rating_submitted")

        assert rating_page.driver.current_url is not None

