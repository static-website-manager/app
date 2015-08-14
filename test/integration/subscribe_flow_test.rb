require 'test_helper'

class SubscribeFlowTest < ActionDispatch::IntegrationTest
  def test_subscription
    visit_subscription_page(assert: true)
  end

  def test_failed_subscription
    visit_subscription_page
    post_via_redirect '/subscribe', invalid_params
    assert_response 422
    assert_equal '/subscribe', path
  end

  def test_successful_subscription
    visit_subscription_page
    post_via_redirect '/subscribe', valid_params
    assert_response 200
    assert path.match(/\A\/websites\/\d+\/setup\z/)
  end

  private

  def invalid_params
    {
      subscription: {
        name: 'Nickname',
      },
    }
  end

  def valid_params
    {
      subscription: {
        user_attributes: {
          name: 'Nickname',
          email: 'first@last.com',
          password: 'password',
          password_confirmation: 'password',
        },
        website_attributes: {
          name: 'Website',
        },
      },
    }
  end

  def visit_subscription_page(assert: false)
    get '/subscribe'

    if assert
      assert_response :success
      assert_select 'form[action="/subscribe"][method="post"]' do
        assert_select 'input[name="subscription[user_attributes][name]"]'
        assert_select 'input[name="subscription[user_attributes][email]"]'
        assert_select 'input[name="subscription[user_attributes][password]"]'
        assert_select 'input[name="subscription[user_attributes][password_confirmation]"]'
        assert_select 'input[name="subscription[website_attributes][name]"]'
        assert_select 'button[type="submit"]'
      end
    end
  end
end
