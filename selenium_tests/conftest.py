import os
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options as ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager

def pytest_addoption(parser):
    parser.addoption(
        "--base-url",
        action="store",
        default="http://localhost:59841",
        help="Base URL of the Flutter Lost and Found web application"
    )
    parser.addoption(
        "--headless",
        action="store_true",
        default=False,
        help="Run browser in headless mode"
    )

@pytest.fixture(scope="session")
def base_url(request):
    return request.config.getoption("--base-url")

@pytest.fixture(scope="function")
def driver(request):
    options = ChromeOptions()
    if request.config.getoption("--headless"):
        options.add_argument("--headless=new")
    
    options.add_argument("--window-size=1280,800")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    
    # Initialize Chrome Driver via webdriver-manager
    service = ChromeService(ChromeDriverManager().install())
    web_driver = webdriver.Chrome(service=service, options=options)
    web_driver.implicitly_wait(10)
    
    yield web_driver
    
    # Take screenshot on test failure
    if hasattr(request.node, "rep_call") and request.node.rep_call.failed:
        os.makedirs("selenium_tests/screenshots", exist_ok=True)
        screenshot_path = f"selenium_tests/screenshots/{request.node.name}.png"
        web_driver.save_screenshot(screenshot_path)
        print(f"\n[Screenshot saved]: {screenshot_path}")

    web_driver.quit()

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, "rep_" + rep.when, rep)
