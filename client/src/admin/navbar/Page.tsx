import type { ReactNode } from "react";
import { FaBars } from "react-icons/fa";
import { NavLink } from "react-router-dom";

interface NavbarProps {
  outlet: ReactNode;
}

export const Navbar: React.FC<NavbarProps> = ({ outlet }) => {
  return (
    <div className="drawer">
      <input id="my-navbar" type="checkbox" className="drawer-toggle" />
      <div className="drawer-content flex flex-col">
        {/* Navbar */}
        <div className="navbar bg-[#FFF0CE] w-full">
          <div className="flex-none lg:hidden">
            <label
              htmlFor="my-navbar"
              aria-label="open sidebar"
              className="btn btn-square btn-ghost"
            >
              <FaBars />
            </label>
          </div>
          <div className="mx-2 flex-1 px-2 text-[#3396D3] font-bold text-[1.6rem]">
            Le Château Bleu
          </div>
          <div className="hidden flex-none lg:block">
            <ul className="menu menu-horizontal gap-1">
              {/* Navbar menu content here */}
              <li>
                <NavLink
                  to={"/admin/reservations"}
                  className={({ isActive }) =>
                    isActive ? "bg-[#3396D3] text-white" : ""
                  }
                >
                  Reservations
                </NavLink>
              </li>
              <li>
                <NavLink
                  to={"/admin/orders"}
                  className={({ isActive }) =>
                    isActive ? "bg-[#3396D3] text-white" : ""
                  }
                >
                  Orders
                </NavLink>
              </li>
              <li>
                <NavLink
                  to={"/admin/menu"}
                  className={({ isActive }) =>
                    isActive ? "bg-[#3396D3] text-white" : ""
                  }
                >
                  Menu
                </NavLink>
              </li>
              <li>
                <NavLink
                  to={"/admin/tables"}
                  className={({ isActive }) =>
                    isActive ? "bg-[#3396D3] text-white" : ""
                  }
                >
                  Tables
                </NavLink>
              </li>
            </ul>
          </div>
        </div>
        {/* Page content here */}
        {outlet}
      </div>
      <div className="drawer-side">
        <label
          htmlFor="my-navbar"
          aria-label="close sidebar"
          className="drawer-overlay"
        ></label>
        <ul className="menu bg-base-200 min-h-full w-80 p-4">
          {/* Sidebar content here */}
          <li>
            <a>Sidebar Item 1</a>
          </li>
          <li>
            <a>Sidebar Item 2</a>
          </li>
        </ul>
      </div>
    </div>
  );
};
