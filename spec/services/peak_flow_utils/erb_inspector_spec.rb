require "rails_helper"

describe PeakFlowUtils::ErbInspector do
  let(:erb_inspector) do
    PeakFlowUtils::ErbInspector.new(
      dirs: [Rails.root.to_s]
    )
  end

  let(:files) { erb_inspector.files.to_a }
  let(:file_paths) { files.map(&:file_path) }

  describe "#files" do
    it "finds the correct number of files" do
      expect(files.length).to eq 47
    end

    it "finds haml-files" do
      expect(file_paths).to include "app/views/users/index.html.haml"
    end

    it "finds js-files" do
      expect(file_paths).to include "app/assets/javascripts/translations.js"
    end

    it "finds erb-files" do
      expect(file_paths).to include "app/views/users/show.html.erb"
    end
  end
end
