package com.example.navan.stocksearch;

import android.app.Activity;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Toast;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.api.GoogleApiClient;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    private GoogleApiClient client;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        AutoCompleteTextView text = (AutoCompleteTextView) findViewById(R.id.autoComplete);
        text.setAdapter(new SuggestionAdapter(this,text.getText().toString()));
    }

    public void onGetQuoteTap(View v) {
        Toast myToast = Toast.makeText(getApplicationContext(), "Get Quote Pressed", Toast.LENGTH_LONG);
        myToast.show();
    }
}

    class JsonParseAutoComplete {

        public List<SuggestGetSet> getJsonData(String symbol){
            List<SuggestGetSet> data = new ArrayList<SuggestGetSet>();
            try {
                String temp = symbol.replace(" ","%20");
                URL url = new URL("http://stocksearch.itzugpsbwa.us-west-2.elasticbeanstalk.com/?action="+temp);
                URLConnection conn = url.openConnection();
                BufferedReader response = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String line = response.readLine();
                JSONArray json = new JSONArray(line);
                for (int i=0;i<json.length();i++){
                    JSONObject ob = json.getJSONObject(i);
                    data.add(new SuggestGetSet(ob.getString("Symbol"),ob.getString("Name")));
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return data;
        }
    }

    class SuggestGetSet {

        String symbol,name;
        public SuggestGetSet(String symbol, String name){
            this.setSymbol(symbol);
            this.setName(name);
        }
        public String getSymbol() {
            return symbol;
        }

        public void setSymbol(String symbol) {
            this.symbol = symbol;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

    }

    class SuggestionAdapter extends ArrayAdapter<String> {

        protected static final String TAG = "SuggestionAdapter";
        
        private List<String> suggestions;
        public SuggestionAdapter(Activity context, String nameFilter) {
            super(context, android.R.layout.simple_dropdown_item_1line);
            suggestions = new ArrayList<String>();
        }
        @Override
        public int getCount() {
            return suggestions.size();
        }

        @Override
        public String getItem(int index) {
            return suggestions.get(index);
        }
        public Filter getFilter() {
            Filter myFilter = new Filter() {
                @Override
                protected FilterResults performFiltering(CharSequence constraint) {
                    FilterResults filterResults = new Filter.FilterResults();
                    JsonParseAutoComplete jp=new JsonParseAutoComplete();
                    if (constraint != null) {
                        // A class that queries a web API, parses the data and
                        // returns an ArrayList<GoEuroGetSet>
                        List<SuggestGetSet> new_suggestions =jp.getJsonData(constraint.toString());
                        suggestions.clear();
                        for (int i=0;i<new_suggestions.size();i++) {
                            suggestions.add(new_suggestions.get(i).getName());
                        }

                        // Now assign the values and count to the FilterResults
                        // object
                        filterResults.values = suggestions;
                        filterResults.count = suggestions.size();
                    }
                    return filterResults;
                }
                protected void publishResults(CharSequence contraint,
                                              FilterResults results) {
                    if (results != null && results.count > 0) {
                        notifyDataSetChanged();
                    } else {
                        notifyDataSetInvalidated();
                    }
                }
            };
            return myFilter;
    }

}
