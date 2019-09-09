describe Catalog::NextName, :type => :service do
  let(:portfolio) { create(:portfolio) }
  let(:portfolio_item) { create(:portfolio_item, :portfolio => portfolio) }
  let(:portfolio_item2) { create(:portfolio_item, :portfolio => portfolio) }

  let(:next_name) { described_class.new(portfolio_item.id, portfolio.id).process.next_name }

  describe "#process" do
    context "when there isn't a conflicting name" do
      it "returns the name prefixed with copy" do
        expect(next_name).to match(/^Copy of.*/)
      end
    end

    context "copy when there is a copy already" do
      before { portfolio_item2.update(:display_name => "Copy of " + portfolio_item.display_name) }
      it "returns the name with a counter" do
        expect(next_name).to match(/^Copy \(1\) of.*/)
      end
    end
  end
end
