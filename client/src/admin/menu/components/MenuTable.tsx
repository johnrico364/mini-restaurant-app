import { useMenu } from "../hooks/useMenu";

interface MenuTableProps {
  name: string;
  category: string;
  price: number;
  description: string;
  available: boolean;
}

export const MenuTable = () => {
  const { data: menus, isLoading } = useMenu();

  if (isLoading) {
    return (
      <div className="text-[1.8rem] font-bold">
        Loading menu data please wait...{" "}
      </div>
    );
  }

  return (
    <div>
      <div className="overflow-x-auto">
        <table className="table">
          {/* head */}
          <thead>
            <tr>
              <th></th>
              <th>Name</th>
              <th>Category</th>
              <th>Price</th>
              <th>Description</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {menus?.map((menu: MenuTableProps, i: number) => {
              return (
                <tr>
                  <th>{i + 1}</th>
                  <td>{menu.name}</td>
                  <td>{menu.category}</td>
                  <td>₱ {menu.price}</td>
                  <td>{menu.description}</td>
                  <td>
                    {menu.available ? (
                      <div className="text-green-600">Available</div>
                    ) : (
                      <div className="text-red-600">Not available</div>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};
