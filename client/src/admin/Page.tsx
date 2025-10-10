import { Outlet } from "react-router-dom";
import { Navbar } from "./navbar/Page";

export const AdminPage = () => {
  return (
    <>
      <Navbar outlet={<Outlet />}/>
    </>
  );
};
