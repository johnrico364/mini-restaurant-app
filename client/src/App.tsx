import "./App.css";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";

// Pages
import { AdminPage } from "./admin/Page";
import { Tables } from "./admin/tables/Page";
import { Customers } from "./admin/customers/Page";
import { Orders } from "./admin/orders/Page";
import { Menu } from "./admin/menu/Page";

function App() {
  return (
    <div>
      <Router>
        <Routes>
          <Route
            path="/"
            element={<Navigate to={"/admin/customers"} replace />}
          />

          <Route path="/admin" element={<AdminPage />}>
            <Route path="customers" element={<Customers />} />
            <Route path="orders" element={<Orders />} />
            <Route path="menu" element={<Menu />} />
            <Route path="tables" element={<Tables />} />
          </Route>
          
        </Routes>
      </Router>
    </div>
  );
}

export default App;
