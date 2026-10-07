from selenium.webdriver.common.by import By
from pages.base_page import BasePage

class AppNavigationPage(BasePage):
    """
    Page Object Model for navigating across all core screens & routes in the application.
    """
    
    ROUTES = {
        "welcome": "/welcome",
        "login": "/login",
        "register": "/register",
        "home": "/home",
        "ai_search": "/ai-search",
        "ai_scan": "/ai-scan",
        "create_post": "/create-post-step1",
        "my_posts": "/my-posts",
        "map_view": "/map-view",
        "chats": "/chats",
        "notifications": "/notifications",
        "profile": "/profile",
        "edit_profile": "/edit-profile",
        "favorites": "/favorites",
        "history": "/history",
        "rewards": "/rewards",
        "leaderboard": "/leaderboard",
        "recovery_history": "/recovery-history",
        "wallet": "/wallet",
        "nid_verification": "/nid-verification",
        "police_gd": "/police-gd",
        "admin": "/admin",
        "settings": "/settings",
        "help": "/help",
        "privacy_terms": "/privacy-terms",
        "about": "/about",
    }

    def navigate_to_route(self, route_key):
        path = self.ROUTES.get(route_key, "/")
        self.navigate_to(path)
        return self.driver.current_url
