public class PieChartController {
    public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('North', 30, 60));
        data.add(new PieWedgeData('South', 15, 30));
        data.add(new PieWedgeData('East', 20, 30));
        data.add(new PieWedgeData('West', 20, 40));
        
        return data;
    }

    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }
        public Integer data1 { get; set; }

        public PieWedgeData(String name, Integer data,Integer data1) {
            this.name = name;
            this.data = data;
            this.data1 = data1;
        }
    }
}