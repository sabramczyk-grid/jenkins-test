import pytest
from helloworld import app

# Create a test client for the Flask application


@pytest.fixture
def client():
    app.config['TESTING'] = True

    # Create a test client using the Flask application configured for testing
    with app.test_client() as client:
        yield client


def test_root_route(client):
    """Tests whether the root route returns the correct status code and content."""

    # Simulate a GET request to the root URL
    response = client.get('/')

    # 1. Check if the status code is 200 (OK)
    assert response.status_code == 200

    # 2. Check if the response contains our expected text
    expected_text = "Hello World from Jenkins, Terraform and Flask!"

    # Decode response data from bytes to string and check for expected text
    assert expected_text in response.data.decode('utf-8')
