require 'spec_helper'

describe FormatParser do

  class NoEscapes
    def escape_sequences; []; end
  end

  let(:formatter) { NoEscapes.new }

  subject { FormatParser.new(formatter) }

  it "should keep characters together" do
    subject.parse("foo").must_equal ["foo"]
  end

  it "should break apart format characters" do
    subject.parse('%a').must_equal [['a']]
  end

  it "should not include blanks" do
    subject.parse('%a%b').must_equal [['a'],['b']]
  end

  it "should handle strings with format characters inside" do
    subject.parse('foo%bar').must_equal ['foo', ['b'], 'ar']
  end

  describe "Simple multicharacter escapes" do

    class MulticharEscapes
      def escape_sequences; ['foo']; end
    end

    let(:formatter) { MulticharEscapes.new }

    it "should handle multiformat escapes" do
      subject.parse("%foo").must_equal [['foo']]
    end

  end

  describe "Greedy multicharacter escapes" do

    class GreedyMulticharEscapes
      def escape_sequences; %w(f fo foo); end
    end

    let(:formatter) { GreedyMulticharEscapes.new }

    it "should handle multiformat escapes" do
      subject.parse("%foo").must_equal [['foo']]
    end

    it "should get the longest first" do
      subject.parse("%foo%fo%f").must_equal [['foo'], ['fo'], ['f']]
    end

  end

  describe "Escaping regex punctuation" do

    class RegexEscapes
      def escape_sequences; %w(++); end
    end

    let(:formatter) { RegexEscapes.new }

    it "should not get confused when a regex symbol is an escape char" do
      subject.parse('%++').must_equal [['++']]
    end

  end


end
