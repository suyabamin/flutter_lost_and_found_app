import pytest
from pages.app_navigation_page import AppNavigationPage

@pytest.mark.navigation
class TestAllPagesNavigation:

    @pytest.mark.parametrize("route_key", [
        "welcome",
        "login",
        "register",
        "home",
        "ai_search",
        "ai_scan",
        "create_post",
        "my_posts",
        "map_view",
        "chats",
        "notifications",
        "profile",
        "edit_profile",
        "favorites",
        "history",
        "rewards",
        "leaderboard",
        "recovery_history",
        "wallet",
        "nid_verification",
        "police_gd",
        "admin",
        "settings",
        "help",
        "privacy_terms",
        "about"
    ])
    def test_page_route_renders(self, driver, base_url, route_key):
        """Verify that every route across the application renders successfully."""
        nav_page = AppNavigationPage(driver, base_url)
        current_url = nav_page.navigate_to_route(route_key)
        nav_page.take_screenshot(f"route_{route_key}")
        assert current_url is not None
        assert base_url in current_url

