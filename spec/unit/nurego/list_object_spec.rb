require File.expand_path('../../test_helper', __FILE__)

describe "Nurego::ListObject" do
  xit "be able to retrieve full lists given a listobject" do
    @mock.should_receive(:get).twice.and_return(test_response(test_charge_array))
    c = Nurego::Charge.all
    c.kind_of?(Nurego::ListObject).should be_true
    c.url.should eq('/v1/charges')
    all = c.all
    all.kind_of?(Nurego::ListObject).should be_true
    all.url.should eq('/v1/charges')
    all.data.kind_of?(Array).should be_true
  end
end
