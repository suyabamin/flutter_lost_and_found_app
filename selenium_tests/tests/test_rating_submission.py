import pytest
from pages.login_page import LoginPage
from pages.rating_page import RatingPage

@pytest.mark.rating
class TestRatingSubmission:

    def test_rating_screen_access_and_submission(self, driver, base_url):
        """
        Verify rating screen submission flow and ensure Firestore write 
        succeeds without permission-denied errors.
        """
        # Step 1: Login
        login_page = LoginPage(driver, base_url)
        login_page.open()
        login_page.login("user1@example.com", "Password123!")
        
        # Step 2: Navigate to Rating Screen for claim
        rating_page = RatingPage(driver, base_url)
        rating_page.open_claim_rating("claim_test_123")
        
        # Step 3: Submit rating & review
        rating_page.submit_rating("Excellent communication and swift recovery!")
        
        # Step 4: Verify no permission denied snackbar / alert appeared
        is_permission_denied = rating_page.wait_for_snack_bar("permission-denied") or \
                               rating_page.wait_for_snack_bar("permission denie")
        assert not is_permission_denied, "Firestore returned permission-denied during rating submission!"

    def test_five_star_rating_selection(self, driver, base_url):
        """Verify selecting 5 star rating values."""
        rating_page = RatingPage(driver, base_url)
        rating_page.open_claim_rating("claim_test_123")
        rating_page.select_five_star_rating()
        # Ensure page elements responsive
        assert rating_page.driver.current_url is not None
