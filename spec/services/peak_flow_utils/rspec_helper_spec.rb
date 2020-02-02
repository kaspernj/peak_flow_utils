require "rails_helper"

describe PeakFlowUtils::RspecHelper do
  it "forwards the tag command to rspec" do
    helper = PeakFlowUtils::RspecHelper.new(groups: 4, group_number: 2, tags: ["~@firefox_skip", "asd"])
    command = helper.__send__(:dry_result_command)
    expect(command).to eq "bundle exec rspec --dry-run --format json --tag ~@firefox_skip --tag asd"
  end

  it "doesnt include the tag argument if nothing is given" do
    helper = PeakFlowUtils::RspecHelper.new(groups: 4, group_number: 2)
    command = helper.__send__(:dry_result_command)
    expect(command).to eq "bundle exec rspec --dry-run --format json"
  end

  it "selects only given types" do
    helper = PeakFlowUtils::RspecHelper.new(groups: 4, group_number: 2, only_types: ["system"])

    ignore_models = helper.__send__(:ignore_type?, "models")
    ignore_system = helper.__send__(:ignore_type?, "system")

    expect(ignore_models).to eq true
    expect(ignore_system).to eq false
  end

  describe "#sorted_files" do
    it "falls back to sort the files by name" do
      helper = PeakFlowUtils::RspecHelper.new(groups: 4, group_number: 2)

      expect(helper).to receive(:files).and_return(
        "specs/file_b_spec.rb" => {
          examples: 1,
          path: "specs/file_b_spec.rb",
          points: 1
        },
        "specs/file_c_spec.rb" => {
          examples: 1,
          path: "specs/file_c_spec.rb",
          points: 1
        },
        "specs/file_a_spec.rb" => {
          examples: 1,
          path: "specs/file_a_spec.rb",
          points: 1
        }
      )

      files = helper.sorted_files.map { |file| file.fetch(:path) }

      expect(files).to eq [
        "specs/file_a_spec.rb",
        "specs/file_b_spec.rb",
        "specs/file_c_spec.rb"
      ]
    end
  end
end