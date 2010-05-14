class Object
  def to_a
    self.is_a?(Array) ? self : [self]
  end
end

class Array
  def map_key_value(key=nil, &block)
    self.map{|elem| [(key.nil? ? elem : elem.__send__(key.to_sym)), (block_given? ? block.call(elem) : elem)] }
  end
  alias_method :mapkeyvalue, :map_key_value
  def to_hash
    acts_as_key_value!(:to_hash)
    Hash[*self.consolidate.inject([]){|array, pair| array << pair.first << pair.last}]
  end
  def group_key_value(attribute, &block)
    self.mapkeyvalue(attribute, &block).consolidate
  end
  alias_method :groupkeyvalue, :group_key_value
  def consolidate
    acts_as_key_value!(:consolidate)
    keys, index = {}, -1
    kv = self.dup
    kv.delete_if do |pair|
      index += 1
      key_index = keys[pair.first]
      if key_index
        kv[key_index][1] = kv[key_index][1].to_a + pair.last.to_a
      else
        keys[pair.first] = index
      end
      key_index
    end
  end
  def expand
    acts_as_key_value!(:expand)
    self.inject([]) do |result, pair|
      result + pair.last.to_a.map{|val| [pair.first, val]}
    end
  end
 
  def flip
    acts_as_key_value!(:swap)
    self.map{|pair| [pair.last, pair.first]}
  end

  def invert_key_value
    acts_as_key_value!(:invert)
    self.expand.flip.consolidate
  end
  alias_method :invert, :invert_key_value

  def keys
    acts_as_key_value!(:keys)
    self.map{|pair| pair.first }
  end
  def values
    acts_as_key_value!(:values)
    self.map{|pair| pair.last }
  end
  private
  def acts_as_key_value!(method)
     raise "Cannot call '#{method}' on an non-key-value array" unless (self.empty? || self.first.is_a?(Array) && self.first.size == 2)
  end
end

class Hash
  def map_key_value(key=nil, &block)
    self.map{|first, last| [(key.nil? ? first : last.__send__(key.to_sym)), (block_given? ? block.call(first, last) : last)]}
  end
  alias_method :mapkeyvalue, :map_key_value
  def invert_key_value
    self.to_a.invert_key_value
  end
  alias_method :invert, :invert_key_value
end

