require 'rails_helper'

RSpec.describe IngenuityScraper, type: :model do
  let!(:ingenuity) { create(:rover, name: "Ingenuity", landing_date: Date.new(2021, 2, 18), launch_date: Date.new(2020, 7, 30), status: "active") }
  let(:scraper) { IngenuityScraper.new }

  describe "#rover" do
    it "should be Ingenuity" do
      expect(scraper.rover).to eq ingenuity
    end
  end

  describe ".collect_links" do
    it "should return links to each sol" do
      expect(scraper.collect_links).to include "https://mars.nasa.gov/rss/api/?feed=raw_images&category=ingenuity&feedtype=json&sol=1"
    end
  end

  describe ".scrape" do
    let!(:helincam) { create :camera, rover: ingenuity, name: "HELI_NAV" }
    let!(:helirdcam) { create :camera, rover: ingenuity, name: "HELI_RTE" }

    before(:each) do
      allow(scraper).to receive(:collect_links).and_return ["https://mars.nasa.gov/rss/api/?feed=raw_images&category=ingenuity&feedtype=json&sol=1"]
    end

    it "should create photo objects" do
      expect{ scraper.scrape }.to change { Photo.count }.by(34)
    end

    context "finds an invalid camera name" do
      before(:each) do
        allow($stdout).to receive(:write) # stub stdout
        allow(scraper).to receive(:camera_from_json).and_return('NOT_A_CAMERA')
      end

      it "should not create any photos" do
        expect { scraper.scrape }.to change { Photo.count }.by(0)
      end

      it "should print a warning" do
        expect { scraper.scrape }.to output(/WARNING: Camera not found. Name: NOT_A_CAMERA/).to_stdout
      end
    end
  end
end
