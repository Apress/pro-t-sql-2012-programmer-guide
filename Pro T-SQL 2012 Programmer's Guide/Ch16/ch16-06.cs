using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WCFdsClient.PhotoServiceReference;
using System.Data.Services.Client;

namespace WCFdsClient
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            PopulateDropDown();
        }

        private void PopulateDropDown() 
        { 
            AdventureWorksEntities ctx = new AdventureWorksEntities(
                new Uri ("http://localhost:59560/ProductPhotoDataService.svc")
                );

            var qry = from p in ctx.Products   
                      where p.FinishedGoodsFlag
                      orderby p.Name
                      select p;
            
            foreach (Product p in qry) {
                ProductDropDown.Items.Add(new ListItem(p.Name, p.ProductID.ToString())); 
            }
            
            string id = ProductDropDown.SelectedValue; 
            UpdateImage(id); 
        }

        private void UpdateImage(string id) {
            ProductImage.ImageUrl = string.Format("GetImage.aspx?id={0}", id);
        }

        protected void ProductDropDownlist_SelectedIndexChanged(object sender, EventArgs e)
        {
            string id = ProductDropDown.SelectedValue;

            AdventureWorksEntities ctx = new AdventureWorksEntities(
                new Uri("http://localhost:59560/ProductPhotoDataService.svc")
                );

            var qry = from p in ctx.Products
                      where p.ProductID == Convert.ToInt32(id)
                      select p;

            //DataServiceOuery<Product> qry = ctx.CreateOuery<Product>(string.Format("/Product({0})", id));

            foreach (Product p in qry)
            {
                TableProduct.Rows[0].Cells[1].Text = p.Class;
                TableProduct.Rows[1].Cells[1].Text = p.Color;
                TableProduct.Rows[2].Cells[1].Text = p.Size + " " + p.SizeUnitMeasureCode;
                TableProduct.Rows[3].Cells[1].Text = p.Weight + " " + p.WeightUnitMeasureCode;
                TableProduct.Rows[4].Cells[1].Text = p.ListPrice.ToString();
                TableProduct.Rows[5].Cells[1].Text = p.ProductNumber;
            }
            UpdateImage(id); 
        }

    }

}
