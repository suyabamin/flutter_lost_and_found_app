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
        default="http://localhost:49576",
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

    # Emulate Mobile Screen (Mobile device viewport layout)
    mobile_emulation = {
        "deviceMetrics": { "width": 412, "height": 915, "pixelRatio": 2.6 },
        "userAgent": "Mozilla/5.0 (Linux; Android 13; Mobile Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
    }
    options.add_experimental_option("mobileEmulation", mobile_emulation)
    options.add_argument("--window-size=430,930")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    
    # Initialize Chrome Driver via webdriver-manager
    service = ChromeService(ChromeDriverManager().install())
    web_driver = webdriver.Chrome(service=service, options=options)
    web_driver.implicitly_wait(10)
    
    yield web_driver
    
    # Automatically take and save screenshot at the end of EVERY test
    screenshots_dir = os.path.join(os.getcwd(), "selenium_tests", "screenshots")
    os.makedirs(screenshots_dir, exist_ok=True)
    
    raw_name = request.node.name.replace("[", "_").replace("]", "_").replace("/", "_")
    status = "FAILED" if (hasattr(request.node, "rep_call") and request.node.rep_call.failed) else "PASSED"
    screenshot_path = os.path.join(screenshots_dir, f"{raw_name}_{status}.png")
    
    try:
        web_driver.save_screenshot(screenshot_path)
        print(f"\n[Mobile Screenshot saved]: {screenshot_path}")
    except Exception as e:
        print(f"\n[Screenshot Notice]: {e}")

    web_driver.quit()

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, "rep_" + rep.when, rep)

