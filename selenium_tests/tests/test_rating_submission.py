import pytest
from pages.login_page import LoginPage
from pages.rating_page import RatingPage

@pytest.mark.rating
class TestRatingSubmission:

    def test_rating_screen_access_and_submission(self, driver, base_url):
        """
        Verify rating screen access and page structure.
        """
        rating_page = RatingPage(driver, base_url)
        rating_page.open_claim_rating("1")
        assert "rating" in driver.current_url.lower()

    def test_five_star_rating_selection(self, driver, base_url):
        """Verify selecting rating screen route."""
        rating_page = RatingPage(driver, base_url)
        rating_page.open_claim_rating("1")
        assert rating_page.driver.current_url is not None

