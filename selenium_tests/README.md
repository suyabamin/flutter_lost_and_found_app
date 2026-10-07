# Selenium Automated Testing Suite for Flutter Lost & Found Web

This directory contains a complete Page Object Model (POM) automated test suite built with **Python**, **Selenium WebDriver**, and **pytest** for testing the Flutter Lost & Found Web Application.

---

## 📁 Directory Structure

```
selenium_tests/
├── conftest.py             # Pytest fixtures & Selenium WebDriver Chrome configuration
├── pytest.ini              # Pytest configuration & markers
├── requirements.txt        # Python package dependencies
├── pages/
│   ├── base_page.py        # Base Page Object with Flutter Web semantics handlers
│   ├── login_page.py       # Page Object for Login & Authentication screens
│   └── rating_page.py      # Page Object for Rating & Review submission
└── tests/
    ├── test_auth.py              # Test cases for user login and guest access
    └── test_rating_submission.py # Test cases for rating submission & Firestore verification
```

---

## 🚀 Setup & Installation

### 1. Prerequisites
- Python 3.9+ installed
- Google Chrome browser installed

### 2. Install Dependencies
Navigate to `selenium_tests` directory and install required Python packages:

```bash
cd selenium_tests
pip install -r requirements.txt
```

---

## 🧪 Running the Tests

### 1. Run Flutter Web Locally
Ensure your Flutter Web application is running (e.g. on port `3000` or `8080`):

```bash
flutter run -d chrome --web-port=3000
```

### 2. Execute Selenium Test Suite

Run all test cases:
```bash
pytest --base-url=http://localhost:3000
```

Run tests in **Headless Mode** (ideal for CI/CD pipelines):
```bash
pytest --base-url=http://localhost:3000 --headless
```

Run specific test files or marked test suites:
```bash
# Run only authentication tests
pytest tests/test_auth.py --base-url=http://localhost:3000

# Run only rating submission tests
pytest tests/test_rating_submission.py --base-url=http://localhost:3000
```

---

## 🛠️ Flutter Web Semantics & Element Interaction

Flutter Web renders UI inside canvas and glass elements. The `BasePage` automatically triggers Flutter Web semantics tree generation (`flt-semantics-placeholder`) so Selenium can locate elements using standard DOM selectors, ARIA labels, and text contents.
