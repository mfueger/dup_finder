require "spec_helper"
require_relative "../../dup_finder"

describe DupFinder do
  subject { DupFinder.new({}) }

  it { should respond_to(:dirs) }

  its(:dirs) { should be_an_instance_of(Array) }
  its(:file_sizes) { should be_an_instance_of(Hash) }
  its(:dups) { should be_an_instance_of(Array) }

  context "with the test directory" do
    before { subject.send(:get_file_sizes, 'spec/test_data') }

    it "determines the correct size for files" do
      subject.file_sizes.length.should be 1
      subject.file_sizes[4].length.should be 3
    end

    it "determines the dups" do
      subject.should_receive(:get_dups_from_group).with(["spec/test_data/test1", "spec/test_data/test2"]).and_return(['spec/test_data/test2'])
      subject.send(:find_dups)
    end
  end
end