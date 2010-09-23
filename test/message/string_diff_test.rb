require "./test/test_helper"
require "wrong/assert"
require "wrong/message/string_diff"
require "wrong/adapters/minitest"

describe "when you're comparing strings and they don't match, show me the diff message" do
  
  def assert_string_diff_message(first_string, second_string, str)
    assert{
      rescuing{
        assert{first_string == second_string}
      }.message.include?(str)
    }
  end
  
  it "don't attempt to do this if the assertion is not of the form a_string==b_string" do
    deny{
      rescuing{
        assert{1==2}
      }.message.include?("diff")
    }
    deny{
      rescuing{
        assert{"a"==2}
      }.message.include?("diff")
    }
    deny{
      rescuing{
        assert{1=="a"}
      }.message.include?("diff")
    }
    deny{
      rescuing{
        assert{nil=="a"}
      }.message.include?("diff")
    }
  end

  it "simple" do
    assert{
      rescuing{
        assert{"a"=="b"}
      }.message.include?("diff")
    }
    
    assert_string_diff_message("ab", "acc",  %{
ab
 ^ 
acc
 ^^
})
  end

  it "whitespace" do
    assert_string_diff_message("a\nb", "a\ncc",  %{
a\\nb
  ^ 
a\\ncc
  ^^
})

    assert_string_diff_message("a\tb", "a\tcc",  %{
a\\tb
  ^ 
a\\tcc
  ^^
})
    assert_string_diff_message("a\rb", "a\rcc",  %{
a\\rb
  ^ 
a\\rcc
  ^^
})

  end

  it "elides really long matching sections" do
    skip

    left = "x"*100 + "ab" + "y"*100 + "AB" + "z"*100 
    right = "x"*100 + "acc" + "y"*100 + "ACC" + "z"*100 
    
    assert_string_diff_message("ab", "acc",  %{
...xxabyyy....yyABzzz....
      ^          ^       
...xxaccyyy...yyACCzzz...
      ^^         ^^     
})
  end
  
end
