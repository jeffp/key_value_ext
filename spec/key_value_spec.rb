require 'ostruct'
require File.dirname(__FILE__) + '/../lib/key_value_ext'


describe 'mapkeyvalue' do
  describe 'with no param and no block' do
    describe 'for an array' do
      it "should may the elements to themselves maintaining order" do
        [:a, :b, :c].mapkeyvalue.should == [[:a, :a], [:b, :b], [:c, :c]]
      end
    end
    describe 'for a hash ' do
      it "should group by the key and produce a 2-dim key-value array with no guaranteed order" do
        {:a=>1, :b=>2, :c=>3}.mapkeyvalue.should =~ [[:a, 1], [:b, 2], [:c, 3]]
      end
    end
  end
  describe 'with no param but with a block' do
    describe 'for an array' do
      it "should group the block content by the array elements maintaining order" do
        [:a, :b, :c].mapkeyvalue{|elem| elem.to_s }.should == [[:a, 'a'], [:b, 'b'], [:c, 'c']]
      end
    end
    describe 'for a hash' do
      it "should group the block content by the hash keys producing a key-value array with no guaranteed order" do
        {:a=>1, :b=>2, :c=>3}.mapkeyvalue{|k, v| k.to_s + v.to_s }.should =~ [[:a, 'a1'], [:b, 'b2'], [:c, 'c3']]
      end
    end
  end
  describe 'with a param but with no block' do
    describe 'for an array of objects' do
      it "should group the array elements by the value/object returned by the method specified in the param" do
        a, b, c = OpenStruct.new(:meth=>1), OpenStruct.new(:meth=>2), OpenStruct.new(:meth=>3)
        [a, b, c].mapkeyvalue(:meth).should == [[1, a], [2, b], [3, c]]
      end
    end
    describe 'for a hash' do
      it "should group the values by the value/object returned by the method specified in the param" do
        a, b, c = OpenStruct.new(:meth=>1), OpenStruct.new(:meth=>2), OpenStruct.new(:meth=>3)
        {:a=>a, :b=>b, :c=>c}.mapkeyvalue(:meth).should =~ [[1,a], [2,b], [3,c]]
      end
    end
  end
end

describe 'consolidate' do
  describe 'for a non-key-value array' do
    it "should raise exception" do
      lambda { [1, 2, 3].consolidate }.should raise_exception(/consolidate/)
    end
  end
  describe 'for a key-value array' do
    it "should consolidate values into arrays grouped by the same key maintaining first-in-line order" do
      [[:a, 1], [:b, 2], [:c, 3], [:a, 4]].consolidate.should == [[:a, [1,4]], [:b, 2], [:c, 3]]
    end
  end
end

describe 'to_hash' do
  describe 'for a non-key-value array' do
    it "should raise exception" do
      lambda { [1,2,3].to_hash }.should raise_exception(/to_hash/)
    end
  end
  describe 'for a key-value array' do
    it "should return a hash of keys containing values array preserving values with arrays" do
      [[:a, 1], [:b, [2,3]], [:c, nil]].to_hash.should == {:a=>1, :b=>[2,3], :c=>nil}
    end
    it "should consolidate duplicate keys" do
      [[:a, 1], [:b, [2,3]], [:c, nil], [:a, 5]].to_hash.should == {:a=>[1,5], :b=>[2,3], :c=>nil}
    end
  end
end

describe 'keys' do
  describe 'for a non-key-value array' do
    it "should raise exception" do
      lambda { [1,2,3].keys }.should raise_exception(/keys/)
    end
  end
  describe 'for a key-value array' do
    it "should return an array of the keys" do
      [[:a, 1], [:b, 2], [:c, 3]].keys.should == [:a, :b, :c]
    end
  end
end

describe 'values' do
  describe 'for a non-key-value array' do
    it "should raise exception" do
      lambda { [1,2,3].values }.should raise_exception(/values/)
    end
  end
  describe 'for a key-value array' do
    it "should return an array of the values" do
      [[:a, 1], [:b, 2], [:c, 3]].values.should == [1,2,3]
    end
  end
end

describe 'expand' do
  describe 'for a non-key-value array' do
    it "should raise exception" do
      lambda { [1,2,3].expand }.should raise_exception(/expand/)
    end
  end
  describe 'for a key-value array' do
    it "should break out arrays of values" do
      [[:a, [1, 2]], [:b, 1], [:c, [4,5]]].expand.should == [[:a,1],[:a,2],[:b,1],[:c,4],[:c,5]]
    end
  end
end

describe 'invert_key_value' do
  describe 'for a non-key-value array' do
    it "should raise exception" do
      lambda { [1,2,3].invert_key_value }.should raise_exception(/invert/)
    end
  end
  describe 'for a key-value array' do
    it "should return a key-value array with keys constructed from values referencing previous keys preserving order" do
      [[:a, 1], [:b, 2], [:c, 3]].invert_key_value.should == [[1, :a], [2, :b], [3, :c]]
    end
    it "should invert for values with arrays" do
      [[:a, [1,2]], [:b, 2], [:c, [3,2]]].invert_key_value.should == [[1, :a], [2, [:a,:b,:c]], [3, :c]]
    end
  end
end

describe 'Object.to_a' do
  it 'should convert an object to an array unless it is an array' do
    1.to_a.should == [1]
    'str'.to_a.should == ['str']
    [1,'str'].to_a.should == [1,'str']
  end
end

