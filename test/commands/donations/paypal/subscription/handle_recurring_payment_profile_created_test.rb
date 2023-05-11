require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreatedTest < Donations::TestBase
  test "creates subscription" do
    freeze_time do
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create(:user, paypal_payer_id:)
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated.(payload)

      refute Donations::Payment.exists?
      assert_equal 1, Donations::Subscription.count
      subscription = Donations::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert user.reload.active_donation_subscription?
    end
  end

  test "creates subscription for unknown paypal payer id but known email" do
    freeze_time do
      recurring_payment_id = SecureRandom.uuid
      paypal_payer_id = SecureRandom.uuid
      user = create :user
      amount_in_dollars = 15
      amount_in_cents = amount_in_dollars * 100
      payload = {
        "recurring_payment_id" => recurring_payment_id,
        "txn_type" => "recurring_payment_profile_created",
        "payment_status" => "Completed",
        "payer_email" => user.email,
        "payer_id" => paypal_payer_id,
        "mc_gross" => "#{amount_in_dollars}.0"
      }

      Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated.(payload)

      refute Donations::Payment.exists?
      assert_equal 1, Donations::Subscription.count
      subscription = Donations::Subscription.last
      assert_equal recurring_payment_id, subscription.external_id
      assert_equal amount_in_cents, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :paypal, subscription.provider
      assert user.reload.active_donation_subscription?
    end
  end

  test "ignore when paypal payer id and email are unknown" do
    payload = {
      "recurring_payment_id" => SecureRandom.uuid,
      "txn_type" => "recurring_payment_profile_created",
      "payment_status" => "Completed",
      "payer_email" => "unknown@test.org",
      "payer_id" => SecureRandom.uuid,
      "mc_gross" => "15.0"
    }

    Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated.(payload)

    refute Donations::Payment.exists?
    refute Donations::Subscription.exists?
  end
end
