require File.expand_path('../../test_helper', __FILE__)

module Nurego
  class ListObjectTest < Test::Unit::TestCase
    should "be able to retrieve full lists given a listobject" do
      @mock.expects(:get).twice.returns(test_response(test_charge_array))
      c = Nurego::Charge.all
      assert c.kind_of?(Nurego::ListObject)
      assert_equal('/v1/charges', c.url)
      all = c.all
      assert all.kind_of?(Nurego::ListObject)
      assert_equal('/v1/charges', all.url)
      assert all.data.kind_of?(Array)
    end
  end
end
