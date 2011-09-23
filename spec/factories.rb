FactoryGirl.define do
  sequence :category_name do |n|
    "Category ##{n}"
  end

  factory :assessment do
    title { "A title" }
    association :category
  end

  factory :assessment_with_test, :parent => :assessment do
    test_content_type "text/html"
    test_file_name "somefile.html"
    test_file_size 100
  end

  factory :category do
    name { Factory.next(:category_name) }
  end

  factory :link do
    url "http://google.com"
    description "this is google"
  end
end
