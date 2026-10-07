import time
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

class BasePage:
    def __init__(self, driver, base_url):
        self.driver = driver
        self.base_url = base_url
        self.wait = WebDriverWait(driver, 15)

    def navigate_to(self, path=""):
        clean_path = path.lstrip('/')
        if clean_path:
            formatted_path = f"/#/{clean_path}" if not clean_path.startswith("#") else f"/{clean_path}"
        else:
            formatted_path = "/"
        url = f"{self.base_url.rstrip('/')}{formatted_path}"
        self.driver.get(url)
        self.enable_flutter_semantics()

    def enable_flutter_semantics(self):
        """
        Enables accessibility semantics tree for Flutter Web to expose
        DOM elements and input nodes to Selenium.
        """
        try:
            time.sleep(2)  # Wait for initial Flutter script load
            js_script = """
                let placeholder = document.querySelector('flt-semantics-placeholder');
                if (placeholder) {
                    placeholder.click();
                }
            """
            self.driver.execute_script(js_script)
            time.sleep(1)
        except Exception as e:
            print(f"[Notice] Semantics trigger notice: {e}")

    def find(self, by, value):
        return self.wait.until(EC.presence_of_element_located((by, value)))

    def find_visible(self, by, value):
        return self.wait.until(EC.visibility_of_element_located((by, value)))

    def click(self, by, value):
        element = self.wait.until(EC.element_to_be_clickable((by, value)))
        element.click()

    def type_text(self, by, value, text):
        element = self.find(by, value)
        element.clear()
        element.send_keys(text)

    def get_text(self, by, value):
        element = self.find_visible(by, value)
        return element.text

    def is_element_present(self, by, value, timeout=5):
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located((by, value))
            )
            return True
        except TimeoutException:
            return False

    def wait_for_snack_bar(self, expected_text=None):
        """
        Waits for Flutter SnackBar / Notification to appear on screen.
        """
        try:
            if expected_text:
                xpath = f"//*[contains(text(), '{expected_text}')]"
                return self.is_element_present(By.XPATH, xpath, timeout=8)
            else:
                return self.is_element_present(By.XPATH, "//*[contains(@class, 'snack') or contains(@role, 'alert')]", timeout=8)
        except Exception:
            return False
